# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
Rails.application.load_tasks

if Rails.env.development? || Rails.env.test?

  require 'rubocop'
  require 'rubocop/rake_task'

  if defined? RuboCop
    desc "Run style checker"
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.requires << "rubocop-rspec"
      task.fail_on_error = true
    end

    desc "Run test suite and style checker"
    task spec: :rubocop
  end
end
