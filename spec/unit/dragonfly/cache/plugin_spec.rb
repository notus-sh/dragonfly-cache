# frozen_string_literal: true

describe Dragonfly::Cache::Plugin do
  let(:tmp) { Dir.mktmpdir('dc', File.join(Dir.pwd, 'tmp')) }
  let(:app) do
    server_root = tmp

    app = dragonfly_test_app
    app.configure do
      plugin :dragonfly_cache,
             url_format: '/dragonfly-cache/:sha/:name',
             server_root: server_root
    end
    app
  end
  let(:jobs) do
    {
      basic: sample_job(app, type: :basic),
      text: sample_job(app, type: :text),
      text2: sample_job(app, type: :text2)
    }
  end

  after do
    FileUtils.rmtree(tmp, secure: true)
  end

  it 'returns a cache url' do
    jobs.each_value do |job|
      expect(app.url_for(job)).to start_with('/dragonfly-cache/')
    end
  end

  it 'returns a clean url' do
    jobs.each_value do |job|
      # We know the name is the last part of the url
      expect(File.basename(app.url_for(job))).to match(/[[:alnum:]-]/)
    end
  end

  it 'returns an url with correct file extension' do
    jobs.each_value do |job|
      # We know the name is the last part of the url
      expect(File.extname(app.url_for(job)).to_s.delete_prefix('.')).to eq(job.ext.to_s)
    end
  end

  # rubocop:disable RSpec/IdenticalEqualityAssertion
  it 'always returns the same url for a given job' do
    jobs.each_value do |job|
      expect(app.url_for(job)).to eq(app.url_for(job))
    end
  end
  # rubocop:enable RSpec/IdenticalEqualityAssertion

  it 'returns different urls for different jobs' do
    expect(app.url_for(jobs[:basic])).not_to eq(app.url_for(jobs[:text]))
  end

  it 'stores the job result at the returned url' do
    jobs.each_value do |job|
      File.open(File.join(tmp, app.url_for(job)), 'rb') do |f|
        expect(f.read).to eq(job.content.data)
      end
    end
  end

  context 'with multiple jobs' do
    # 2 letters sha-ish may go from '00' to 'ff'. Test at least one more
    let(:shaish_range) { 0x00..(rand(0xFF..0x110)) }

    it 'increases :sha size to avoid key collisions' do
      job = sample_job(app, type: :image)
      shaish_set = shaish_range.each_with_object(Set.new) do |i, set|
        set << File.basename(File.dirname(job.thumb("#{i}x#{i}").url))
      end

      expect(shaish_set.size).to eq(shaish_range.size)
    end
  end

  it 'prevents future processing of an image' do
    allow(Dragonfly::ImageMagick::Commands).to receive(:convert).once
    job = sample_job(app, type: :image)
    job.thumb('80x80').url
    job.thumb('80x80').url

    expect(Dragonfly::ImageMagick::Commands).to have_received(:convert).once
  end
end
