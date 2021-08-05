# frozen_string_literal: true

require 'csv'

##
# Harvest research data from DataSpace for indexing
class ResearchDataHarvester
  COLLECTION_CONFIG = Rails.root.join('config', 'collections.csv')
  REST_LIMIT = 100

  def collections_to_index
    collections = []
    CSV.foreach(COLLECTION_CONFIG, quote_char: '"', col_sep: ',', row_sep: :auto, headers: true) do |row|
      rdc = ResearchDataCollection.new(row)
      collections << rdc
    end
    collections
  end

  ##
  # For a given ResearchDataCollection, retrieve its metadata from DataSpace
  # @param [ResearchDataCollection] research_data_collection
  def harvest(research_data_collection)
    server = 'https://dataspace-dev.princeton.edu/rest'
    collection_id = research_data_collection.collection_id
    url = "#{server}/collections/#{collection_id}/items?limit=#{REST_LIMIT}&offset=0&expand=all"

    resp = Faraday.get(url, {}, { 'Accept': 'application/xml' })
    Indexer.new(resp.body).index
  end

  ##
  # Convenience method to harvest and index all collections in the config file
  # @example
  #   ResearchDataHarvester.harvest
  def self.harvest
    r = ResearchDataHarvester.new
    r.collections_to_index.each do |collection|
      Rails.logger.info "Harvesting collection id #{collection.collection_id}"
      r.harvest(collection)
    end
  end
end
