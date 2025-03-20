# frozen_string_literal: true

require "health_monitor/providers/cache"

class PULCache < HealthMonitor::Providers::Cache
  private

  def key
    random = rand(99)
    @key ||= ["health", request.try(:remote_ip), random].join(":")
  end
end
