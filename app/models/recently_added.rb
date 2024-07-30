# frozen_string_literal: true

class RecentlyAdded
  def self.feed
    solr_url = Blacklight.default_configuration.connection_config[:url]
    solr = RSolr.connect(url: solr_url)
    solr_params = {
      q: '*:*',
      fq: 'migrated_bsi:false',
      sort: 'pdc_updated_at_dtsi desc'
    }
    response = solr.get('select', params: solr_params)
    entries = response["response"]["docs"].map { |doc| SolrDocument.new(doc) }
    entries
  rescue StandardError => ex
    Rails.logger.warn "Error fetching recently added feed: #{ex.message}."
    []
  end
end
