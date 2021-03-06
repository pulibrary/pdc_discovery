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
end
