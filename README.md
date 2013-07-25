The Collector
====================

The collector collects data related to the app's git repo current state upon application start and sends it using a POST request to any uri of your choice.
The collector has been designed to work best with [ARMA](https://github.com/semiweb/arma).

## Installation

```ruby
gem 'the_collector', :git => "https://github.com/semiweb/the_collector.git"
```

## Usage

Create an initializer like so:

```ruby
thread = Thread.new do
  Collector.setup do |config|
    config.application       = 'App Name'
    config.installation      = 'Installation Name'
    config.location          = 'Installation Location'
    config.env               = 'Environment'
    config.github_repo       = 'Github Repo Name'
    config.uri               = 'http://[url]'
    config.authorization_key = 'betchaCantFindThis'
  end
end

thread.join
```

`uri`: replace [url] with the place where you want to post this data to. 

`authorization_key`: by setting an authorization key to be sent with the data you can check the authenticity of the request in your other application.

And you're done ; )
