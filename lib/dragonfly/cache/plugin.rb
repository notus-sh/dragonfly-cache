# frozen_string_literal: true

require 'uri'
require 'dragonfly/cache/config'
require 'dragonfly/cache/manager'

module Dragonfly
  module Cache
    class Plugin
      extend Forwardable

      @@servers = {}

      attr_reader :config, :manager

      delegate %i[servers_options] => :config
      delegate %i[sha_size valid_uri? store] => :manager

      def call(app, cache_servers_options = {})
        @config   = Dragonfly::Cache::Config.new(cache_servers_options)
        @manager  = Dragonfly::Cache::Manager.new(self)

        app.define_url do |app, job, opts|
          url_for(app, job, opts)
        rescue Dragonfly::Cache::Error => e
          Dragonfly.warn(e.message)
          app.server.url_for(job, opts) # Fallback to default Dragonfly::App url building
        end
      end

      protected

      def url_for(app, job, opts)
        uri = find_valid_url_for(app, job, opts)
        # File are stored on url building instead of in a before_serve block to allow use of assets host
        store(job, uri)
        uri.to_s
      end

      def find_valid_url_for(app, job, opts)
        loop do
          url = server_for(app).url_for(job, options_for(job).merge(opts))
          uri = URI.parse(url)
          uri.query = nil
          uri.fragment = nil
          return uri if valid_uri?(job, uri)
        end
      end

      def options_for(job)
        {
          shaish: job.sha[0..(sha_size - 1)]
        }
      end

      def server_for(app)
        @@servers[app.name] ||= begin
          server = app.server.dup
          servers_options.each do |name, value|
            server.send("#{name}=", value) if server.respond_to?("#{name}=")
          end
          server
        end
      end
    end
  end
end
