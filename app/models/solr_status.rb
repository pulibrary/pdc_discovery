# frozen_string_literal: true
class SolrStatus < HealthMonitor::Providers::Base
  # @note No test coverage for error handling but depends on API call
  def check!
    uri = Blacklight.default_index.connection.uri
    status_uri = URI(uri.to_s.gsub(uri.path, '/solr/admin/cores?action=STATUS'))
    response = Net::HTTP.get(status_uri)
    json = JSON.parse(response)
    if json["responseHeader"]["status"] != 0
      raise "The solr has an invalid status #{status_uri}"
    end
  end
end
