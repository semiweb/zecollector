require 'date'
require 'httparty'

class Collector
  include HTTParty

  class << self
    attr_accessor :application, :installation, :location, :env, :git_path, :uri, :github_repo, :authorization_key

    def setup
      yield self
      base_uri uri
      options = {
        state: {
          ref:           `cd #{path} && git rev-parse HEAD`.strip,
          branch:        `cd #{path} && git rev-parse --abbrev-ref HEAD`.strip,
          local_changes: !`cd #{path} && git status -s`.strip.empty?,
          diff:          `cd #{path} && git diff`
        },
        application:       { name: application },
        installation:      { name: installation, location: location, env: env },
        authorization_key: ENV['ARMA_AUTHORIZATION_KEY']
      }
      post('/', body: options)
    end

    def path
      git_path || Rails.root
    end
  end
end