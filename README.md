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
Collector.setup do |config|
  config.application       = 'App Name'
  config.installation      = 'Installation Name'
  config.location          = 'Installation Location'
  config.uri               = 'http://[url]'
  config.authorization_key = 'betchaCantFindThis'

  config.on_exception do |exception|
    log_exception(exception)
  end
end
```

`uri`: replace [url] with the place where you want to post this data to. 

`authorization_key`: by setting an authorization key to be sent with the data you can check the authenticity of the request in your other application.

And you're done ; )

Here is the data structure of what will be sent:

```ruby
{
  state: {
    ref:           ref,
    local_commits: number,
    branch:        branch,
    diff:          diff,
    github_repo:   name
  },
  application:       { name: application },
  installation:      { name: installation, location: location, env: Rails.env },
  authorization_key: authorization_key
}
```

`ref`: last commit sha that is also present on remote (`origin`)

`local_commits`: the number of commits after this one that are not on remote

`branch`: the current git branch

`diff`: result of the `git diff` command

`github_repo`: name of your applications's github repository

`application`: name contains the name of your app

`installation`: we consider that an application can be installed at different places (multiple clients) hence these fields