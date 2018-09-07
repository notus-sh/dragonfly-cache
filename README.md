# dragonfly-cache

`dragonfly-cache` is a cache adapter for [Dragonfly](http://markevans.github.io/dragonfly/). It allows you to store Dragonfly's jobs results without running them again and again on each call. 

**For now**, `dragonfly-cache` supports only local caching of local files. It will be extended in a near future to support remote cache and file storages. 

## Installation

Add `dragonfly-cache` to your application's Gemfile:

```ruby
gem 'dragonfly-cache'
```

And then execute:

```shell
bundle install
```

Or install it yourself as:

```shell
gem install dragonfly-cache
```

## Configuration

Once installed, you should configure `dragonfly-cache` to set your application's root (`/public` by default, if the directory exists) and your cached url format (`/dragonfly-cache/:sha/:name` by default).

```ruby
Dragonfly.app.configure do
  plugin :dragonfly_cache,
    server_root: Rails.application.root.join('public'),
    url_format:  '/media-cache/:sha/:name'
end
```

Configured as this, cached files will be stored in `/public/media-cache/:sha/:name`, where `:name` is [the Dragonfly `:name` attribute of the attached file](http://markevans.github.io/dragonfly/models#name-and-extension) and `:sha` is a contraction of the job SHA params.

`dragonfly-cache` will try to do its best to shorten the `:sha` part of the url and prevent cache conflicts.

## How does it work?

`dragonfly-cache` use a method similar to [the one described in the Dragonfly documentation to process files on-the-fly and serve them remotely](http://markevans.github.io/dragonfly/cache#processing-on-the-fly-and-serving-remotely) but use only `define_url`. 
