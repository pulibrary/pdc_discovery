# frozen_string_literal: true

require 'csv'

##
# Harvest research data from DataSpace for indexing
class DspaceResearchDataHarvester
  COLLECTION_CONFIG = Rails.root.join('config', 'collections.csv')
  REST_LIMIT = 100
  CACHE_COMMUNITIES_FILE = Rails.root.join('spec', 'fixtures', 'files', 'dataspace_communities.json')

  def collections_to_index(collection_config = COLLECTION_CONFIG)
    collections = []
    CSV.foreach(collection_config, quote_char: '"', col_sep: ',', row_sep: :auto, headers: true) do |row|
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

  def migration_csv_headers
    ["parent_community", "community", "collection_name", "title", "handle", "ark_url", "doi", "curator", "redescribed", "pdc_describe_id", "data_migrated"]
  end

  def item_title(item_node)
    item_node.xpath("./name").text.strip
  end

  def item_handle(item_node)
    item_node.xpath("./handle").text.strip
  end

  ##
  # Sometimes the DSpace "ParentCommunity,Community,CollectionName" has three levels of hierarchy,
  # sometimes only two. We want the top level to consistently show up as the Parent Community
  # Given an array with three elements, "ParentCommunity,Community,CollectionName",
  # if the ParentCommunity=="NA" shift everything left one space and leave CollectionName blank
  # @param [Array] three_levels
  # @return [Array]
  def csv_communities(three_levels)
    raise "Error assigning parent_community" unless three_levels.count == 3
    return three_levels if three_levels[0] != "NA"
    three_levels[0] = three_levels[1]
    three_levels[1] = three_levels[2]
    three_levels[2] = ""
    three_levels
  end

  ##
  # Given a collection_id and a file location, produce a migration spreadsheet
  def produce_migration_spreadsheet(parent_community, community, collection_name, collection_id, tracking_csv)
    url = "#{server}/collections/#{collection_id}/items"

    resp = Faraday.get(url, {}, { 'Accept': 'application/xml' })
    xml_doc = Nokogiri::XML(resp.body)

    CSV.open(tracking_csv, "a") do |csv|
      xml_doc.xpath("/items/item").each do |item_node|
        handle = item_handle(item_node)
        collection_hierarchy = csv_communities([parent_community, community, collection_name])
        everything_else = [item_title(item_node), handle, "https://dataspace.princeton.edu/handle/#{handle}", '', '', '', '', '']
        csv << collection_hierarchy + everything_else
      end
    end
  end

  ##
  # Delta between migration needed and what's on the in progress spreadsheet
  def delta_migration(parent_community, community, collection_name, collection_id, tracking_csv, in_progress_csv)
    in_progress_data = CSV.parse(File.read(in_progress_csv), headers: true)
    in_progress_handles = in_progress_data.by_col["handle"]
    url = "#{server}/collections/#{collection_id}/items"

    resp = Faraday.get(url, {}, { 'Accept': 'application/xml' })
    xml_doc = Nokogiri::XML(resp.body)

    CSV.open(tracking_csv, "a") do |csv|
      xml_doc.xpath("/items/item").each do |item_node|
        handle = item_handle(item_node)
        next if in_progress_handles.include?(handle)
        collection_hierarchy = csv_communities([parent_community, community, collection_name])
        everything_else = [item_title(item_node), handle, "https://dataspace.princeton.edu/handle/#{handle}", '', '', '', '', '']
        csv << collection_hierarchy + everything_else
      end
    end
  end

  ##
  # Generate a CSV with a row for each DSpace item that needs to be migrated to PDC Describe
  def produce_full_migration_spreadsheet(tracking_csv, collections_csv)
    Rails.logger.info "Generating DSpace migration tracking CSV"
    CSV.open(tracking_csv, "w") do |csv|
      csv << migration_csv_headers
    end
    collections_to_index(collections_csv).each do |collection|
      # TODO: parent community should be pushed to the left if it is NA
      produce_migration_spreadsheet(collection.parent_community, collection.community, collection.collection_name, collection.collection_id, tracking_csv)
    end
  end

  # Generate a CSV with a row for each DSpace item that needs to be migrated
  # and is not yet present in the in_progress spreadsheet
  def produce_delta_migration_spreadsheet(tracking_csv, collections_csv, in_progress_csv)
    Rails.logger.info "Generating DSpace DELTA migration tracking CSV"
    Rails.logger.info "Calculating delta against #{in_progress_csv}"
    CSV.open(tracking_csv, "w") do |csv|
      csv << migration_csv_headers
    end
    collections_to_index(collections_csv).each do |collection|
      delta_migration(collection.parent_community, collection.community, collection.collection_name, collection.collection_id, tracking_csv, in_progress_csv)
    end
  end
end
