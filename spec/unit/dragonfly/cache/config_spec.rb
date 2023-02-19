# frozen_string_literal: true

describe Dragonfly::Cache::Config do
  subject(:config) { described_class }

  it 'validates url_format' do
    expect do
      config.new(url_format: '/something/without/sha', server_root: Dir.pwd)
    end.to raise_error(Dragonfly::Cache::Error, ':url_format option must include `:sha`')
  end

  it 'validates server_root' do
    expect do
      config.new(server_root: File.join(Dir.pwd, 'public'))
    end.to raise_error(Dragonfly::Cache::Error, ':server_root option is missing or directory does not exist')
  end

  it 'sets default values for required options' do
    servers_options = config.new(server_root: File.join(Dir.pwd)).servers_options
    expect(servers_options).to include(:url_format, :server_root)
  end

  it 'accepts to store more options' do
    servers_options = config.new(server_root: File.join(Dir.pwd), any: :option).servers_options
    expect(servers_options).to include(any: :option)
  end
end
