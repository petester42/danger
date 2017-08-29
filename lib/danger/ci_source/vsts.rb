require "danger/request_sources/vsts"

module Danger
    # ### CI Setup
    #
    # Read how you can setup Danger on the buddybuild blog:
    # https://www.buddybuild.com/blog/using-danger-with-buddybuild/
    #
    # ### Token Setup
    #
    # Login to buddybuild and select your app. Go to your *App Settings* and
    # in the *Build Settings* menu on the left, choose *Environment Variables*.
    # http://docs.buddybuild.com/docs/environment-variables
    #
    # #### GitHub
    # Add the `DANGER_GITHUB_API_TOKEN` to your build user's ENV.
    #
    # #### GitLab
    # Add the `DANGER_GITLAB_API_TOKEN` to your build user's ENV.
    #
    # #### Bitbucket Cloud
    # Add the `DANGER_BITBUCKETSERVER_USERNAME`, `DANGER_BITBUCKETSERVER_PASSWORD`
    # to your build user's ENV.
    #
    # #### Bitbucket server
    # Add the `DANGER_BITBUCKETSERVER_USERNAME`, `DANGER_BITBUCKETSERVER_PASSWORD`
    # and `DANGER_BITBUCKETSERVER_HOST` to your build user's ENV.
    #
    # ### Running Danger
    #
    # Once the environment variables are all available, create a custom build step
    # to run Danger as part of your build process:
    # http://docs.buddybuild.com/docs/custom-prebuild-and-postbuild-steps
    class VSTS < CI
      #######################################################################
      def self.validates_as_ci?(env)
        value = env["BUILD_BUILDID"]
        return !value.nil? && !env["BUILD_BUILDID"].empty?
      end
  
      #######################################################################
      def self.validates_as_pr?(env)
        value = env["SYSTEM_PULLREQUEST_PULLREQUESTID"]
        return !value.nil? && !env["SYSTEM_PULLREQUEST_PULLREQUESTID"].empty?
      end
  
      #######################################################################
      def supported_request_sources
        @supported_request_sources ||= [
          Danger::RequestSources::VSTS
        ]
      end
  
      #######################################################################
      def initialize(env)
        team_project = env["SYSTEM_TEAMPROJECT"]
        repo_name = env["BUILD_REPOSITORY_URI"].split('/').last
        
        self.repo_slug = "#{team_project}/#{repo_name}"
        self.pull_request_id = env["SYSTEM_PULLREQUEST_PULLREQUESTID"]
        self.repo_url = env["BUILD_REPOSITORY_URI"]
      end
    end
  end
  