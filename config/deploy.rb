# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "pdc_discovery"
set :repo_url, "https://github.com/pulibrary/pdc_discovery.git"

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
end

after "deploy:published", "pdc_discovery:reindex"
