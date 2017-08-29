# coding: utf-8

require "danger/helpers/comments_helper"

module Danger
  module RequestSources
    class VSTSAPI
      attr_accessor :host, :pr_api_endpoint

      def initialize(_project, slug, pull_request_id, environment)
        @token = environment["DANGER_VSTS_API_TOKEN"]
        @api_version = "3.0"
        self.host = environment["DANGER_VSTS_HOST"]
        if self.host && !(self.host.include? "http://") && !(self.host.include? "https://")
          self.host = "https://" + self.host
        end
        self.pr_api_endpoint = "#{host}/_apis/git/repositories/#{slug}/pullRequests/#{pull_request_id}"
      end

      def credentials_given?
        @token && !@token.empty?
      end

      def fetch_pr_json
        uri = URI("#{pr_api_endpoint}?api-version=#{@api_version}")
        fetch_json(uri)
      end

      def fetch_last_comments
        uri = URI("#{pr_api_endpoint}/threads?api-version=#{@api_version}")
        fetch_json(uri)[:value]
      end

      def delete_comment(thread, id)
        uri = URI("#{pr_api_endpoint}/threads/#{thread}/comments/#{id}?api-version=#{@api_version}")
        delete(uri)
      end

      def post_comment(text)
        uri = URI("#{pr_api_endpoint}/threads?api-version=#{@api_version}")
        body = {
          "comments" => [
            {
              "parentCommentId" => 0,
              "content" => text,
              "commentType" => 1
            }
          ],
          "properties" => {
            "Microsoft.TeamFoundation.Discussion.SupportsMarkdown" => {
              "type" => "System.Int32",
              "value" => 1
            }
          },
          "status" => 1
        }.to_json
        post(uri, body)
      end

      private

      def use_ssl
        return self.pr_api_endpoint.include? "https://"
      end

      def fetch_json(uri)
        req = Net::HTTP::Get.new(uri.request_uri, { "Content-Type" => "application/json", "Authorization" => "Basic #{@token}" })
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl) do |http|
          http.request(req)
        end
        JSON.parse(res.body, symbolize_names: true)
      end

      def post(uri, body)
        req = Net::HTTP::Post.new(uri.request_uri, { "Content-Type" => "application/json", "Authorization" => "Basic #{@token}" })
        req.body = body

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl) do |http|
          http.request(req)
        end

        # show error to the user when VSTS returned an error
        case res
        when Net::HTTPClientError, Net::HTTPServerError
          # HTTP 4xx - 5xx
          abort "\nError posting comment to VSTS: #{res.code} (#{res.message})\n\n"
        end
      end

      def delete(uri)
        req = Net::HTTP::Delete.new(uri.request_uri, { "Content-Type" => "application/json", "Authorization" => "Basic #{@token}" })
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl) do |http|
          http.request(req)
        end
      end
    end
  end
end
