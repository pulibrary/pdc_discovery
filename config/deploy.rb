set :application, "pdc_discovery"
set :repo_url, "https://github.com/pulibrary/pdc_discovery.git"

set :linked_dirs, %w[log public/system public/assets node_modules]

# Default branch is :main
set :branch, ENV["BRANCH"] || "main"

set :deploy_to, "/opt/pdc_discovery"

# This fixes a "Rails manifest file not found" error when deploying to a new server
# for the first time.
# See https://stackoverflow.com/questions/47914115/rails-manifest-file-not-found-deploying-with-capistrano
Rake::Task["deploy:assets:backup_manifest"].clear_actions
Rake::Task["deploy:assets:restore_manifest"].clear_actions

namespace :pdc_discovery do
  desc "Reindex research data"
  task :reindex do
    on roles(:reindex) do
      within release_path do
        execute("cd #{release_path} && bundle exec rake index:research_data")
      end
    end
  end
end

before "deploy:reverted", "deploy:assets:precompile"

# Uncomment to re-index on every deploy. Only needed when we're actively
# updating how indexing happens.
# after "deploy:published", "pdc_discovery:reindex"

namespace :mailcatcher do
  desc "Opens Mailcatcher Consoles"
  task :console do
    on roles(:app) do |host|
      mail_host = host.hostname
      user = "pulsys"
      port = rand(9000..9999)
      puts "Opening #{mail_host} Mailcatcher Console on port #{port} as user #{user}"
      Net::SSH.start(mail_host, user) do |session|
        session.forward.local(port, "localhost", 1080)
        puts "Press Ctrl+C to end Console connection"
        `open http://localhost:#{port}/`
        session.loop(0.1) { true }
      end
    end
  end
end