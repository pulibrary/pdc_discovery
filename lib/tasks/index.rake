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
end
