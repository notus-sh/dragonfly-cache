# frozen_string_literal: true

describe Dragonfly::Cache::Storage do
  let(:tmp) do
    Dir.mktmpdir('dc', File.join(Dir.pwd, 'tmp'))
  end

  after(:each) do
    FileUtils.rmtree(tmp, secure: true)
  end

  # Dragonfly::Cache::Storage only need a Manager instance
  # to fetch servers_options, delegated to a Config object.
  # Let's skip this step.
  let(:manager) { Dragonfly::Cache::Config.new server_root: tmp }
  let(:job) { sample_job(dragonfly_test_app) }
  let(:uri) { URI.parse('/dragonfly-cache/fake/url') }

  subject { Dragonfly::Cache::Storage.new(manager) }

  it "writes job's content to a cache location" do
    subject.write(job, uri)
    File.open(File.join(tmp, uri.path)) do |f|
      f.binmode
      expect(f.read).to eq(job.content.data)
    end
  end

  it 'detects if a cache location is available' do
    expect(subject.writen?(job, uri)).to be_falsey
    subject.write(job, uri)
    expect(subject.writen?(job, uri)).to be_truthy
  end

  it 'detects the maximum sha size in current cache paths' do
    expect(subject.current_max_sha_size).to be_nil # No job stored
    subject.write(job, uri)
    expect(subject.current_max_sha_size).to eq(4) # Size of 'fake'
  end
end
