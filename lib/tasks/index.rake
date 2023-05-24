# frozen_string_literal: true

# Require ImportHelper so we can get the solr leader
require ::Rails.root.join('lib', 'traject', 'import_helper.rb')

namespace :index do
  desc 'Delete index and re-index all research data'
  task research_data_clean_slate: :environment do
    Rails.logger.info "Deleting all Solr documents"
    Rake::Task['index:delete_solr_all'].invoke
    Rails.logger.info "Deleted all Solr documents"
    Rake::Task['index:research_data'].invoke
  end

  desc 'Re-index all research data (without deleting first)'
  task research_data: :environment do
    Rails.logger.info "Research Data indexing started"
    Rake::Task['index:pdc_describe_research_data'].invoke
    Rake::Task['index:dspace_research_data'].invoke
    Rails.logger.info "Research Data indexing completed"
  end

  desc 'Index all DSpace research data collections'
  task dspace_research_data: :environment do
    Rails.logger.info "Harvesting and indexing DataSpace research data collections started"
    DspaceResearchDataHarvester.harvest(false)
    Blacklight.default_index.connection.commit
    Rails.logger.info "Harvesting and indexing DataSpace research data collections completed"
  end

  desc 'Index all PDC Describe data'
  task pdc_describe_research_data: :environment do
    Rails.logger.info "Harvesting and indexing PDC Describe data started"
    DescribeIndexer.new.index
    Blacklight.default_index.connection.commit
    Rails.logger.info "Harvesting and indexing PDC Describe data completed"
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

  task get_solr_writer: :environment do
    puts "--"
    puts Blacklight.default_index.connection.uri
    puts ImportHelper.solr_writer_url
  end

  task update_solr_writer: :environment do
    puts "--"
    puts Blacklight.default_index.connection.uri
    new_writer_url = ImportHelper.solr_writer_url
    puts new_writer_url
    puts ImportHelper.update_solr_alias(Blacklight.default_index.connection.uri, new_writer_url)
  end
end
