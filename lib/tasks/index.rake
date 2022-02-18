# frozen_string_literal: true

namespace :index do
  desc 'Index sample data'
  task sample_data: :environment do
    Indexer.index("foo")
  end

  desc 'Index all research data collections'
  task research_data: :environment do
    puts "Harvesting and indexing research data collections"
    ResearchDataHarvester.harvest
    puts "Done."
  end

  desc 'Remove all indexed Documents from Solr'
  task delete: :environment do
    raise("Deleting indices in Solr is unsupported for the environment #{Rails.env}") if Rails.env.production?

    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
  end

  desc 'Fetches the most recent community information from DataSpace and outputs to the console. Use this to create a cache file.'
  task dataspace_communities: :environment do
    communities = DataspaceCommunities.load_from_dataspace
    puts communities.tree.to_json
  end

  task dataspace_communities_x: :environment do
    communities = DataspaceCommunities.load_from_file('/Users/correah/src/pdc_discovery/spec/fixtures/files/dataspace_communities.json')
    puts communities.find_path(347,[])

    puts communities.find_path(346,[])

    byebug
    puts "1"
  end
end
