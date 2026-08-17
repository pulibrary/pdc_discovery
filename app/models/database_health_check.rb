# frozen_string_literal: true

require "health_monitor/providers/cache"

class DatabaseHealthCheck < HealthMonitor::Providers::Base
  # This health check attempts to execute a simple SQL query to verify that the database connection is working.
  def check!
    ActiveRecord::Base.connection.execute("SELECT 1")
  rescue StandardError => e
    raise "Database connection failed: #{e.message}"
  end
end
