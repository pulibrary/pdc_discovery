# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

require_relative 'lando_env'

# Require the gems listed in Gemfile, but only the default ones
# and those for the environment rails is running in
Bundler.require(*Rails.groups)

module PdcDiscovery
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.exceptions_app = routes

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Use semantic logger for Rails logging
    # See https://logger.reidmorrison.com/rails.html for more
    # We want a .log file, because that's fast, and a .json file,
    # because that's structured and can be parsed by signoz.
    config.rails_semantic_logger.appenders do |appenders|
      appenders.add(file_name: "log/#{Rails.env}.log", formatter: :color)
      appenders.add(file_name: "log/#{Rails.env}.json", formatter: :json)
    end

    config.pdc_discovery = config_for(:pdc_discovery)
  end
end
