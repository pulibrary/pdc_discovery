# frozen_string_literal: true

namespace :index do
  desc 'Index sample data'
  task sample_data: :environment do
    Indexer.index("foo")
  end

  desc 'Index all DSpace research data collections'
  task research_data: :environment do
    puts "Harvesting and indexing research data collections"
    DspaceResearchDataHarvester.harvest(false)
    puts "Done harvesting research data."
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
