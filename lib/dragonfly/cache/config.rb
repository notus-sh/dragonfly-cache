# frozen_string_literal: true

module Dragonfly
  module Cache
    class Config
      attr_accessor :servers_options

      def initialize(servers_options = {})
        self.servers_options = {
          url_format: '/dragonfly-cache/:sha/:name',
          server_root: File.join(Dir.pwd, 'public')
        }.merge(servers_options)

        validate!
        rewrite_url_format!
      end

      protected

      def validate!
        if servers_options[:server_root].nil? || !File.exist?(servers_options[:server_root])
          raise Dragonfly::Cache::Error, ':server_root option is missing or directory does not exist'
        end

        raise Dragonfly::Cache::Error, ':url_format option must include `:sha`' if (servers_options[:url_format] =~ %r{/:sha/}).nil?
      end

      def rewrite_url_format!
        servers_options[:url_format] = servers_options[:url_format].gsub(%r{/:sha}, '/:shaish')
        servers_options[:url_format] = servers_options[:url_format].gsub(%r{/:name}, '/:normalized_name')
      end
    end
  end
end
