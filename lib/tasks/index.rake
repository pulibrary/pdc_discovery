# frozen_string_literal: true

# Require ImportHelper so we can get the solr leader
require ::Rails.root.join('lib', 'traject', 'solr_cloud_helper.rb')

namespace :index do
  desc 'Re-index all research data'
  task research_data: :environment do
    Rails.logger.info "Indexing: Research Data indexing started"
    SolrCloudHelper.create_collection_writer
    Rails.logger.info "Indexing: Created a new collection for writing: #{SolrCloudHelper.collection_writer_url}"

    Rails.logger.info "Indexing: Fetching PDC Describe records"
    Rake::Task['index:pdc_describe_research_data'].invoke
    # ============== Temporarily skip the reindex from DataSpace =========================
    # Rails.logger.info "Indexing: Fetching DataSpace records"
    # Rake::Task['index:dspace_research_data'].invoke
    # ====================================================================================
    Rails.logger.info "Indexing: Fetching completed"

    SolrCloudHelper.update_solr_alias!
    Rails.logger.info "Indexing: Updated Solr to read from the new collection: #{SolrCloudHelper.alias_url} -> #{SolrCloudHelper.collection_reader_url}"
  end

  desc 'Index all DSpace research data collections'
  task dspace_research_data: :environment do
    Rails.logger.info "Indexing: Harvesting and indexing DataSpace research data collections started"
    DspaceResearchDataHarvester.harvest(false)
    SolrCloudHelper.collection_writer_commit!
    Rails.logger.info "Indexing: Harvesting and indexing DataSpace research data collections completed"
  end

  desc 'Index all PDC Describe data'
  task pdc_describe_research_data: :environment do
    Rails.logger.info "Indexing: Harvesting and indexing PDC Describe data started"
    DescribeIndexer.new.index
    SolrCloudHelper.collection_writer_commit!
    Rails.logger.info "Indexing: Harvesting and indexing PDC Describe data completed"
  end

  desc 'Remove all indexed Documents from Solr'
  task delete_solr_all: :environment do
    Rails.logger.info "Deleting all Solr documents"
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
  end

  desc 'Fetches the most recent community information from DataSpace and saves it to a file.'
  task cache_dataspace_communities: :environment do
    cache_file = ENV['COMMUNITIES_FILE'] || './spec/fixtures/files/dataspace_communities.json'
    communities = DataspaceCommunities.new
    File.write(cache_file, JSON.pretty_generate(communities.tree))
  end

  desc 'Prints to console the current Solr URLs and how they are configured'
  task print_solr_urls: :environment do
    puts "Solr alias.: #{SolrCloudHelper.alias_url}"
    puts "Solr reader: #{SolrCloudHelper.collection_reader_url}"
    puts "Solr writer: #{SolrCloudHelper.collection_writer_url}"
  end

  desc 'Updates the Solr alias to point to the most up to date collection'
  task update_solr_alias: :environment do
    puts "Solr updated: #{SolrCloudHelper.update_solr_alias!}"
    Rake::Task['index:print_solr_urls'].invoke
  end

  desc 'Index fixture data'
  task fixtures: :environment do
    indexer = DescribeIndexer.new

    fixture_names = ['pdc_describe_active_embargo.json', 'pdc_describe_expired_embargo.json']
    fixture_names.each do |fixture_name|
      fixture_path = Rails.root.join("spec", "fixtures", "files", fixture_name)
      fixture_json = File.read(fixture_path)
      indexer.index_one(fixture_json)
    end
    SolrCloudHelper.collection_writer_commit!
  end
end
