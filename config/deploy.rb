set :application, "pdc_discovery"
set :repo_url, "https://github.com/pulibrary/pdc_discovery.git"

set :linked_dirs, %w(log public/system public/assets)

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
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && bundle exec rake index:dspace_research_data && bundle exec rake index:pdc_describe_research_data")
      end
    end
  end
end

# Uncomment to re-index on every deploy. Only needed when we're actively 
# updating how indexing happens.
after "deploy:published", "pdc_discovery:reindex"
