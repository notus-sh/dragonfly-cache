# frozen_string_literal: true

Dragonfly.logger = Logger.new('./tmp/dragonfly.log')

def dragonfly_test_app(name = nil)
  app = Dragonfly::App.instance(name)
  app.configure do
    plugin :imagemagick
  end
  app.datastore = Dragonfly::MemoryDataStore.new
  app.secret = 'test secret'
  app
end
