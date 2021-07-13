# frozen_string_literal: true

namespace :index do
  desc 'Index sample data'
  task sample_data: :environment do
    Indexer.index("foo")
  end
end
