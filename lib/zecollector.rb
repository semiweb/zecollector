require 'httparty'
require 'thread'

class Collector
  include HTTParty

  class << self
    attr_accessor :application, :installation, :location, :uri, :authorization_key, :exception_callback

    def setup!(&block)
      Thread.new(self) do |_self|
        yield _self
        _self.base_uri uri
        begin
          raise 'Missing authorization key' unless authorization_key
          _self.post('/', body: options)
        rescue => e
          _self.exception_callback.call(e)
        end
      end
    end

    def setup(&block)
      setup!(&block) unless defined?(Rails::Console) || File.basename($0) == 'rake'
    end

    def options
      lookup = remote_lookup
      {
        state: {
          ref:           lookup[:ref],
          message:       lookup[:message],
          local_commits: lookup[:local_commits],
          branch:        `git rev-parse --abbrev-ref HEAD`.strip,
          diff:          `git diff`,
          github_repo:   `git config --get remote.origin.url`.strip.rpartition('/').last.match('(.*).git')[1]
        },
        application:       { name: application },
        installation:      { name: installation, location: location, env: Rails.env },
        authorization_key: authorization_key
      }
    end

    def remote_lookup
      i, found = 0, false
      until found do
        ref          = `git rev-parse HEAD~#{i}`.strip
        message      = `git log -1 --pretty=%B`.strip
        check_remote = `git branch -r --contains #{ref}`.strip
        found        = check_remote.include? 'origin'
        i += 1
      end
      { ref: ref, message: message, local_commits: i-1 }
    end

    def on_exception(&block)
      self.exception_callback = block
    end
  end
end