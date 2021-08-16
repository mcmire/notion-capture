begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task(default: :spec)
rescue LoadError
  # don't worry about it
end

namespace :notion do
  desc 'Run Notion capture'
  task :capture do
    require 'bundler/setup'
    require_relative 'lib/notion_capture'
    NotionCapture.run
    puts 'Successfully kicked off Notion capture jobs.'
  end
end
