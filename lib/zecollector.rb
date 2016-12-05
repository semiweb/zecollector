require 'httparty'
require 'thread'

class Collector
  include HTTParty

  class << self
    attr_accessor :application, :installation, :location, :uri, :authorization_key, :exception_callback, :code_changelog

    def setup!(&block)
      Thread.new(self) do |_self|
        begin
          yield _self
          _self.base_uri uri
          raise 'Missing authorization key' unless authorization_key
          options_to_use = self.options # No need to recalculate in each attempts and exception right away if needed.
          error_message = nil
          [0, 5, 15, 60].each do |seconds|
            sleep seconds
            begin
              error_message = nil
              response = _self.post('/', body: options_to_use)
            rescue => e
              # so we need to catch the exception here to loop again and retry in some seconds
              # otherwise a post related timeout exception would be rescued by the parent block and no retry happens
              message = e.to_s.encode('utf-16', :invalid => :replace, :undef => :replace).encode('utf-8')
              error_message = "#{e.class}: #{message}\n#{e.backtrace.join("\n")}"
            else
              break if response.code == 200
              error_message = "Error #{response.code}: #{response.message}"
            end
          end
          raise("Unable to send data to arma:\n#{error_message}") if error_message
          _self.code_changelog.commit if defined?(CodeChangelog)
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
      obj = {
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

      if defined?(CodeChangelog)
        self.code_changelog = CodeChangelog::ClientCodeChangelog.new
        obj[:code_changelogs] = code_changelog.changelogs_diff
      end

      obj
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