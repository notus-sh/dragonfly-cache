# frozen_string_literal: true

module Dragonfly
  module Cache
    class Storage
      extend Forwardable

      attr_reader :manager

      delegate %i[servers_options] => :manager

      def initialize(manager)
        @manager = manager
        check_directory!(base_dir)
      end

      def current_max_sha_size
        longest = Dir["#{base_dir}/*"].select { |p| File.directory?(p) }.max { |a, b| a <=> b }
        (longest ? File.basename(longest).size : nil)
      end

      def write(job, uri)
        path = cache_path(uri)
        check_directory!(File.dirname(path))
        with_umask(0o022) do
          job.to_file(path, mode: 0o644, mkdirs: false)
        end
      end

      def writen?(_job, uri)
        File.exist?(cache_path(uri))
      end

      def base_dir
        @base_dir ||= begin
          path_format = File.join(servers_options[:server_root], servers_options[:url_format])
          path_format.split('/').take_while { |p| p != ':shaish' }.join('/')
        end
      end

      protected

      def check_directory!(directory)
        return if File.exist?(directory) && File.directory?(directory) && File.writable?(directory)
        with_umask(0o022) do
          File.unlink(directory) if File.exist?(directory) && !File.directory?(directory)
          FileUtils.mkdir_p(directory, mode: 0o755) unless File.exist?(directory)
          File.chmod(0o755, directory) unless File.writable?(directory)
        end
      rescue ::StandardError => e
        raise Dragonfly::Cache::Error, e.message
      end

      def with_umask(umask)
        original_umask = File.umask(umask)
        begin
          yield
        ensure
          File.umask(original_umask)
        end
      end

      def cache_path(uri)
        File.join(servers_options[:server_root], uri.path)
      end
    end
  end
end
