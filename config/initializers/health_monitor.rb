# frozen_string_literal: true
require "pul_cache"

Rails.application.config.after_initialize do
  HealthMonitor.configure do |config|
    # Use our custom Cache checker instead of the default one
    config.add_custom_provider(PULCache).configure

    config.file_absence.configure do |file_config|
      file_config.filename = "public/remove-from-nginx"
    end
    config.solr.configure do |c|
      c.url = Blacklight.default_index.connection.uri.to_s
      c.collection = Blacklight.default_index.connection.uri.path.split("/").last
    end

    # Make this health check available at /health
    config.path = :health

    config.error_callback = proc do |e|
      unless e.is_a?(HealthMonitor::Providers::FileAbsenceException)
        Rails.logger.error "Health check failed with: #{e.message}"
        Honeybadger.notify(e)
      end
    end
  end
end
