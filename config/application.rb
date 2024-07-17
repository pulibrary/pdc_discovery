# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require_relative 'lando_env'

# Require the gems listed in Gemfile, but only the default ones
# and those for the environment rails is running in
Bundler.require(:default, Rails.env)

module PdcDiscovery
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.exceptions_app = routes

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.eager_load_paths << Rails.root.join("app", "lib")

    config.pdc_discovery = config_for(:pdc_discovery)
  end
end
