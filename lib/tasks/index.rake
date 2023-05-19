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
    solr = RSolr.connect url: ::ImportHelper.solr_leader_url
    solr.commit
    Rails.logger.info "Harvesting and indexing DataSpace research data collections completed"
  end

  desc 'Index all PDC Describe data'
  task pdc_describe_research_data: :environment do
    Rails.logger.info "Harvesting and indexing PDC Describe data started"
    DescribeIndexer.new.index
    solr = RSolr.connect url: ::ImportHelper.solr_leader_url
    solr.commit
    Rails.logger.info "Harvesting and indexing PDC Describe data completed"
  end

  desc 'Remove all indexed Documents from Solr'
  task delete_solr_all: :environment do
    Rails.logger.info "Deleting all Solr documents"
    solr = RSolr.connect url: ::ImportHelper.solr_leader_url
    solr.delete_by_query('*:*')
    solr.commit
  end

  desc 'Fetches the most recent community information from DataSpace and saves it to a file.'
  task cache_dataspace_communities: :environment do
    cache_file = ENV['COMMUNITIES_FILE'] || './spec/fixtures/files/dataspace_communities.json'
    communities = DataspaceCommunities.new
    File.write(cache_file, JSON.pretty_generate(communities.tree))
  end
end
