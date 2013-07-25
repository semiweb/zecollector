The Collector
====================

The collector collects data related to the app's git repo current state upon application start and sends it using a POST request to any uri of your choice.

## Installation

```ruby
gem 'the_collector', :git => "https://github.com/semiweb/the_collector.git"
```

## Usage

Create an initializer like so:

```ruby
thread = Thread.new do
  Collector.setup do |config|
    config.application  = 'App Name'
    config.installation = 'Installation Name'
    config.location     = 'Installation Location'
    config.env          = 'Environment'
    config.github_repo  = 'Github Repo Name'
    config.uri          = 'http://[url]'
  end
end

thread.join
```

Replace [url] with the place where you want to post this data to.

And you're done ; )
