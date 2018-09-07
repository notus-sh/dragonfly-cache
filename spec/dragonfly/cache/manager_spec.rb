# frozen_string_literal: true

describe Dragonfly::Cache::Manager do
  let(:tmp) do
    Dir.mktmpdir('dc', File.join(Dir.pwd, 'tmp'))
  end

  after(:each) do
    FileUtils.rmtree(tmp, secure: true)
  end

  # Dragonfly::Cache::Manager only need a Plugin instance
  # to fetch servers_options, delegated to a Config object.
  # Let's skip this step.
  let(:plugin) { Dragonfly::Cache::Config.new server_root: tmp }
  let(:job) { sample_job(type: :text) }
  let(:uri) { URI.parse('/dragonfly-cache/fake/url') }

  subject { Dragonfly::Cache::Manager.new(plugin) }

  context 'validates cache url' do
    it 'matches job to uri' do
      expect(subject.valid_uri?(job, uri)).to be_truthy # As nothing as been stored yet
      subject.store(job, uri)
      expect(subject.valid_uri?(job, uri)).to be_truthy # Should still be true once something has been stored
    end

    it 'rejects uri reuse' do
      subject.store(job, uri)
      another_job = sample_job(type: :text2)
      expect(subject.valid_uri?(another_job, uri)).to be_falsey
    end

    it 'rejects job.sha reuse' do
      subject.store(job, uri)
      another_uri = URI.parse('/dragonfly-cache/another/url')
      expect(subject.valid_uri?(job, another_uri)).to be_falsey
    end
  end

  it 'reloads cache state' do
    subject.store(job, uri)
    another_manager = Dragonfly::Cache::Manager.new(plugin)
    another_uri = URI.parse('/dragonfly-cache/another/url')

    expect(another_manager.valid_uri?(job, another_uri)).to be_falsey
    expect(another_manager.valid_uri?(job, uri)).to be_truthy
  end
end
