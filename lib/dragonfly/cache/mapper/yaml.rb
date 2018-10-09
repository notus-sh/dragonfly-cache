# frozen_string_literal: true

require 'yaml'

module Dragonfly
  module Cache
    module Mapper
      class Yaml
        extend Forwardable

        attr_reader :root, :internal
        delegate %i[[] key? value? keys values] => :internal

        def initialize(config)
          @root = config[:server_root]
          @internal = {}
          load!
        end

        def store(key, value)
          @internal[key] = value
          save!
        end

        alias []= store

        protected

        def path
          @path ||= File.join(root, 'map.yml')
        end

        def load!
          @internal = File.size?(path) ? YAML.load_file(path) : {}
        end

        def save!
          File.open(path, 'wb') { |f| YAML.dump(@internal, f) }
        end
      end
    end
  end
end
