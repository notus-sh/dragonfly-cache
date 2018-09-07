# frozen_string_literal: true

describe Dragonfly::Cache::Config do
  context 'when instantiated' do
    before(:each) do
      expect_any_instance_of(Dragonfly::Cache::Config).to receive(:validate!).at_least(:once).and_return true
    end

    subject { Dragonfly::Cache::Config.new }

    it 'stores cache servers options' do
      expect(subject).to respond_to(:servers_options)
    end

    it 'sets default values for required options' do
      expect(subject.servers_options).to include(:url_format, :server_root)
    end

    it 'accepts to store more options' do
      config = Dragonfly::Cache::Config.new(any: :option)
      expect(config.servers_options).to include(any: :option)
    end
  end

  context do
    it 'validates required options' do
      expect do
        Dragonfly::Cache::Config.new(
          url_format: '/something/without/sha',
          server_root: Dir.pwd
        )
      end.to raise_error(Dragonfly::Cache::Error, ':url_format option must include `:sha`')

      expect do
        Dragonfly::Cache::Config.new(
          server_root: File.join(Dir.pwd, 'public')
        )
      end.to raise_error(Dragonfly::Cache::Error, ':server_root option is missing or directory does not exist')
    end
  end
end
