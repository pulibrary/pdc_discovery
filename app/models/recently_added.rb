# frozen_string_literal: true

class RecentlyAdded
  def self.feed
    solr = RSolr.connect(url: Blacklight.default_configuration.connection_config[:url])
    solr_params = {
      q: '*:*',
      sort: 'issue_date_strict_ssi desc'
    }
    response = solr.get('select', params: solr_params)
    entries = response["response"]["docs"].map { |doc| SolrDocument.new(doc) }
    entries
  rescue StandardError => ex
    Rails.logger.warn "Error fetching recently added feed: #{ex.message}."
    {}
  end
end
