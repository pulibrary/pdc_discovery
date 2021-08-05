# frozen_string_literal: true

require 'csv'

##
# Harvest research data from DataSpace for indexing
class ResearchDataHarvester
  COLLECTION_CONFIG = Rails.root.join('config', 'collections.csv')

  def collections_to_index
    collections = []
    CSV.foreach(COLLECTION_CONFIG, quote_char: '"', col_sep: ',', row_sep: :auto, headers: true) do |row|
      rdc = ResearchDataCollection.new(row)
      collections << rdc
    end
    collections
  end
end
