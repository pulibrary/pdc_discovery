# frozen_string_literal: true
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Sets the PATH environment variable and run the job
set :job_template, "bash -l -c 'export PATH=\"/usr/local/bin/:$PATH\" && :job'"

# Rebuild index completely every night
# every :day, at: '12:20am', roles: [:reindex] do
#   rake "index:research_data"
# end

# Rebuild index completely every 60 minutes
#
# Bumped the schedule to 60 minutes since it's taking close to 30 minutes now that we are
# indexing datasets with very large number of files.
every 60.minutes, roles: [:reindex] do
  rake "index:research_data"
end
