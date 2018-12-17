# frozen_string_literal: true

describe Dragonfly::Cache::Plugin do
  let(:tmp) do
    Dir.mktmpdir('dc', File.join(Dir.pwd, 'tmp'))
  end

  after(:each) do
    FileUtils.rmtree(tmp, secure: true)
  end

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

  it 'should be called on url building' do
    times = rand(2..4)
    expect_any_instance_of(Dragonfly::Cache::Plugin).to receive(:url_for).exactly(jobs.size * times)
    times.times { jobs.each_value { |job| app.url_for(job) } }
  end

  it 'should return a cache url' do
    jobs.each_value do |job|
      expect(app.url_for(job)).to start_with('/dragonfly-cache/')
    end
  end

  it 'should return a clean url' do
    jobs.each_value do |job|
      # We know the name is the last part of the url
      expect(File.basename(app.url_for(job))).to match(/[[:alnum:]-]/)
    end
  end

  it 'should return an url with correct file extension' do
    jobs.each_value do |job|
      # We know the name is the last part of the url
      expect(File.extname(app.url_for(job)).to_s.gsub(/\A\./, '')).to eq(job.ext.to_s)
    end
  end

  it 'should always return the same url for a given job' do
    jobs.each_value do |job|
      expect(app.url_for(job)).to eq(app.url_for(job))
    end
  end

  it 'should return different urls for different jobs' do
    expect(app.url_for(jobs[:basic])).not_to eq(app.url_for(jobs[:text]))
  end

  it 'should increase :sha size to avoid key collisions' do
    job = sample_job(app, type: :image)

    # 2 letters sha-ish may go from '00' to 'ff'. Test at least one more
    shaish_range = 0x00..(0xFF + rand(10))
    shaish_set = shaish_range.each_with_object(Set.new) do |i, set|
      set << File.basename(File.dirname(job.thumb("#{i}x#{i}").url))
    end

    expect(shaish_set.size).to eq(shaish_range.size)
  end

  it 'should store the job result at the returned url' do
    jobs.each_value do |job|
      File.open(File.join(tmp, app.url_for(job))) do |f|
        f.binmode
        expect(f.read).to eq(job.content.data)
      end
    end
  end

  it 'should prevent future processing of an image' do
    expect_any_instance_of(Dragonfly::ImageMagick::Processors::Convert).to receive(:call).once
    job = sample_job(app, type: :image)
    job.thumb('80x80').url
    job.thumb('80x80').url
  end
end
