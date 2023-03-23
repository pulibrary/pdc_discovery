# frozen_string_literal: true

require 'csv'

##
# Harvest research data from DataSpace for indexing
class DspaceResearchDataHarvester
  COLLECTION_CONFIG = Rails.root.join('config', 'collections.csv')
  REST_LIMIT = 100
  CACHE_COMMUNITIES_FILE = Rails.root.join('spec', 'fixtures', 'files', 'dataspace_communities.json')

  def collections_to_index
    collections = []
    CSV.foreach(COLLECTION_CONFIG, quote_char: '"', col_sep: ',', row_sep: :auto, headers: true) do |row|
      rdc = ResearchDataCollection.new(row)
      collections << rdc
    end
    collections
  end

  def server
    "#{Rails.configuration.pdc_discovery.dataspace_url}/rest"
  end

  ##
  # For a given ResearchDataCollection, retrieve its metadata from DataSpace
  # @param [ResearchDataCollection] collection
  def harvest(collection)
    collection_id = collection.collection_id
    url = "#{server}/collections/#{collection_id}/items?limit=#{REST_LIMIT}&offset=0&expand=all"

    resp = Faraday.get(url, {}, { 'Accept': 'application/xml' })
    DspaceIndexer.new(resp.body).index
  end

  ##
  # Convenience method to harvest and index all collections in the config file
  # @example
  #   DspaceResearchDataHarvester.harvest
  def self.harvest(use_cache = false)
    Rails.logger.info "Harvesting and indexing research data collections has started"

    unless use_cache
      # Fetch latest community information from DataSpace
      communities = DataspaceCommunities.new
      File.write(CACHE_COMMUNITIES_FILE, JSON.pretty_generate(communities.tree))
    end

    # Harvest research data for each collection
    r = DspaceResearchDataHarvester.new
    r.collections_to_index.each do |collection|
      Rails.logger.info "Harvesting collection id #{collection.collection_id}"
      r.harvest(collection)
    end
    Rails.logger.info "Harvesting and indexing research data collections has completed"
  end
end
