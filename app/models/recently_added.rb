# frozen_string_literal: true

class RecentlyAdded
  # @note No coverage for StandardError but depends on library
  def self.feed
    solr_url = Blacklight.default_configuration.connection_config[:url]
    solr = RSolr.connect(url: solr_url)
    solr_params = {
      q: "*:*",
      fq: "migrated_bsi:false",
      sort: "pdc_updated_at_dtsi desc"
    }
    response = solr.get("select", params: solr_params)
    response["response"]["docs"].map { |doc| SolrDocument.new(doc) }
  rescue StandardError => e
    Rails.logger.warn "Error fetching recently added feed: #{e.message}."
    []
  end
end
