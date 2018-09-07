# frozen_string_literal: true

require 'dragonfly/cache/storage'

module Dragonfly
  module Cache
    class Manager
      extend Forwardable

      MIN_SHA_SIZE = 2
      MAX_SHA_SIZE = 16 # Length of SHA identifier generated by Dragonfly

      attr_reader :plugin, :storage, :sha_size

      delegate %i[servers_options] => :plugin
      delegate %i[write writen? current_max_sha_size base_dir] => :storage

      def initialize(plugin)
        @plugin   = plugin
        @storage  = Dragonfly::Cache::Storage.new(self)
        initialize!
      end

      def valid_uri?(job, uri)
        return true unless wrong_key?(job, uri) || wrong_value?(job, uri)
        increase_sha_size!
        false
      end

      def store(job, uri)
        write(job, uri) unless writen?(job, uri)
        map(job, uri)   unless mapped?(job, uri)
      rescue Dragonfly::Cache::Error => e
        Dragonfly.warn(e.message)
      end

      protected

      def wrong_key?(job, uri)
        @cache_map.value?(uri.path) && @cache_map.key(uri.path) != job.sha
      end

      def wrong_value?(job, uri)
        @cache_map.key?(job.sha) && @cache_map[job.sha] != uri.path
      end

      def initialize!
        detect_sha_size
        load_map
      rescue ::StandardError => e
        raise Dragonfly::Cache::Error, e.message
      end

      def detect_sha_size
        @sha_size = [current_max_sha_size, MIN_SHA_SIZE].compact.max
        @sha_size = [@sha_size, MAX_SHA_SIZE].min
      end

      def increase_sha_size!
        raise Error, "Can't build longer :sha identifier" if @sha_size == MAX_SHA_SIZE
        @sha_size += 1

        @cache_map.clear
        save_map
      end

      def map_path
        @map_path ||= File.join(base_dir, 'map.yml')
      end

      def load_map
        @cache_map = File.size?(map_path) ? YAML.load_file(map_path) : {}
      end

      def save_map
        File.open(map_path, 'wb') { |f| YAML.dump(@cache_map, f) }
      end

      def map(job, uri)
        @cache_map[job.sha] = uri.path
        save_map
      end

      def mapped?(job, _uri)
        @cache_map.key?(job.sha)
      end
    end
  end
end
