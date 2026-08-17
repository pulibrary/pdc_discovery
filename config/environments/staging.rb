# frozen_string_literal: true

require_relative "production"

Rails.application.configure do
  # Staging-specific settings here

  config.action_mailer.default_options = {
    from: "noreply@pdc-discovery-staging.princeton.edu"
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "localhost",
    port: 1025
  }
end
