# frozen_string_literal: true

require 'openssl'
require 'dragonfly'

module Dragonfly
  module Cache # :nodoc:
    class Error < ::StandardError; end
  end
end

require 'dragonfly/cache/plugin'
Dragonfly::App.register_plugin(:dragonfly_cache) { Dragonfly::Cache::Plugin.new }
