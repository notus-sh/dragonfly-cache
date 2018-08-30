# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rubocop/rake_task'
RuboCop::RakeTask.new do |task|
  task.options = ['--config', 'config/linters/ruby.yml']
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task default: :spec
