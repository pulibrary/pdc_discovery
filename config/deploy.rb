# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "pdc_discovery"
set :repo_url, "https://github.com/pulibrary/pdc_discovery.git"

set :linked_dirs, %w(log public/system public/assets)

# Default branch is :main
set :branch, ENV["BRANCH"] || "main"

set :deploy_to, "/opt/pdc_discovery"

namespace :pdc_discovery do
  desc "Reindex research data"
  task :reindex do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && bundle exec rake index:research_data")
      end
    end
  end

  desc "Run a yarn install"
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute "cd #{release_path} && yarn install"
        execute "cd #{release_path} && bundle exec rails webpacker:compile"
      end
    end
  end
end

# Uncomment to re-index on every deploy. Only needed when we're actively 
# updating how indexing happens.
after "deploy:published", "pdc_discovery:reindex"
before "deploy:assets:precompile", "pdc_discovery:yarn_install"