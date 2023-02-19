# frozen_string_literal: true

module Dragonfly
  module Cache
    module Storage
      class Local # :nodoc:
        attr_reader :root, :format

        def initialize(config)
          @root = config[:server_root]
          @format = config[:url_format]
        end

        def store(url, job)
          job.to_file(path(url), mode: 0o644)
        end

        def sha_size
          longest = Dir["#{base_dir}/*"].select { |p| File.directory?(p) }.max { |a, b| a <=> b }
          (longest ? File.basename(longest).size : nil)
        end

        protected

        def path(url)
          File.join(root, url)
        end

        def base_dir
          @base_dir ||= begin
            path_format = File.join(root, format)
            path_format.split('/').take_while { |p| p != ':shaish' }.join('/')
          end
        end
      end
    end
  end
end
