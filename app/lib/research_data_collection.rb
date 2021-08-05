# frozen_string_literal: true

require 'csv'

##
# A DataSpace collection that contains research data and should be harvested.
class ResearchDataCollection
  attr_reader :parent_community, :community, :collection_name, :handle, :collection_id, :item_count

  ##
  # Take a CSV::Row and parse it out into the values we'll need at indexing time
  def initialize(csv_row)
    @parent_community = csv_row["ParentCommunity"]
    @community = csv_row["Community"]
    @collection_name = csv_row["CollectionName"]
    @handle = csv_row["Handle"]
    @collection_id = csv_row["CollectionID"]
    @item_count = csv_row["ItemCount"].to_i
  end
end
