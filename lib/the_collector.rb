require 'date'
require 'httparty'

class Collector
  include HTTParty

  class << self
    attr_accessor :application, :installation, :location, :env, :git_path, :uri, :github_repo, :authorization_key

    def setup
      yield self
      base_uri uri
      post('/', body: options)
    end

    def options
      lookup = remote_lookup
      {
        state: {
          ref:           lookup[:ref],
          local_commits: lookup[:local_commits],
          branch:        `cd #{path} && git rev-parse --abbrev-ref HEAD`.strip,
          local_changes: !`cd #{path} && git status -s`.strip.empty?,
          diff:          `cd #{path} && git diff`,
          github_repo:   github_repo
        },
        application:       { name: application },
        installation:      { name: installation, location: location, env: env },
        authorization_key: authorization_key
      }
    end

    def remote_lookup
      i, found = 0, false
      until found do
        ref =          `cd #{path} && git rev-parse HEAD~#{i}`.strip
        check_remote = `cd #{path} && git branch -r --contains #{ref}`.strip
        found =        check_remote.include? 'origin'
        i += 1
      end
      { ref: ref, local_commits: i-1 }
    end

    def path
      git_path || Rails.root
    end
  end
end