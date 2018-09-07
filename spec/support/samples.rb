# frozen_string_literal: true

SAMPLES_DIR = File.join(Dir.pwd, 'spec', 'samples')

def sample_job(app = dragonfly_test_app, type: :basic)
  case type
  when :basic then Dragonfly::Job.new(app, 'content')
  when :text  then app.fetch_file(File.join(SAMPLES_DIR, 'dragonfly.md'))
  when :text2 then app.fetch_file(File.join(SAMPLES_DIR, 'cache (computing).md'))
  end
end
