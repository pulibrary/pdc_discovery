# frozen_string_literal: true

namespace :index do
  desc 'Delete index and re-index all research data'
  task research_data: :environment do
    puts "Deleting index..."
    Rake::Task['index:delete'].invoke
    puts "Indexing PDC Describe data..."
    Rake::Task['index:pdc_describe_research_data'].invoke
    puts "Indexing Data Space research data collections..."
    Rake::Task['index:dspace_research_data'].invoke
    puts "Done."
  end

  desc 'Index all DSpace research data collections'
  task dspace_research_data: :environment do
    puts "Harvesting and indexing DataSpace research data collections"
    DspaceResearchDataHarvester.harvest(false)
    puts "Done harvesting DataSpace research data."
  end

  desc 'Index all PDC Describe data'
  task pdc_describe_research_data: :environment do
    puts "Harvesting and indexing PDC Describe data"
    DescribeIndexer.new.index
    puts "Done harvesting PDC Describe data."
  end

  desc 'Remove all indexed Documents from Solr'
  task delete: :environment do
    raise("Deleting indices in Solr is unsupported for the environment #{Rails.env}") if Rails.env.production?

    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
  end

  desc 'Fetches the most recent community information from DataSpace and saves it to a file.'
  task cache_dataspace_communities: :environment do
    cache_file = ENV['COMMUNITIES_FILE'] || './spec/fixtures/files/dataspace_communities.json'
    communities = DataspaceCommunities.new
    File.write(cache_file, JSON.pretty_generate(communities.tree))
  end
end
