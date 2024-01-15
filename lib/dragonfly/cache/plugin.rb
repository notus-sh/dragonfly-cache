# frozen_string_literal: true

require 'uri'
require 'securerandom'
require 'i18n'
require 'digest/sha1'

require 'dragonfly/cache/config'
require 'dragonfly/cache/manager'

module Dragonfly
  module Cache
    class Plugin # :nodoc:
      extend Forwardable

      # rubocop:disable Style/ClassVars
      @@servers = {}
      # rubocop:enable Style/ClassVars

      attr_reader :config, :manager

      delegate %i[cache valid? job_options] => :manager

      def call(app, cache_servers_options = {})
        @config = Dragonfly::Cache::Config.new(cache_servers_options)
        @manager = Dragonfly::Cache::Manager.new(self)

        app.define_url do |same, job, opts|
          url_for(same, job, opts)
        rescue Dragonfly::Cache::Error => e
          Dragonfly.warn(e.message)
          app.server.url_for(job, opts) # Fallback to default Dragonfly::App url building
        end
      end

      def url_for(app, job, opts)
        cache(job) { build_url_for(app, job, opts) }
      end

      protected

      def build_url_for(app, job, opts)
        loop do
          url = server_for(app).url_for(job, job_options(job).merge(opts))
          path = URI.parse(url).path
          return path if valid?(job, path)
        end
      end

      def server_for(app)
        @@servers[app.name] ||= begin
          server = app.server.dup
          config.servers_options.each do |name, value|
            server.send(:"#{name}=", value) if server.respond_to?(:"#{name}=")
          end
          server
        end
      end
    end
  end
end
