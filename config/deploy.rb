# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "pdc_discovery"
set :repo_url, "https://github.com/pulibrary/pdc_discovery.git"

# Default branch is :main
set :branch, ENV["BRANCH"] || "main"

set :deploy_to, "/opt/pdc_discovery"
