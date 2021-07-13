# frozen_string_literal: true

##
# Index DSpace objects to solr
class Indexer
  ##
  # @param [String] XML from DSpace rest interface
  def initialize(dspace_xml)
    @dspace_xml = dspace_xml
  end

  ##
  # Split the DataSpace response into items and index each one
  def index
    traject_indexer.process(@dspace_xml)
    traject_indexer.complete
  end

  ##
  # Load the traject indexing config for DataSpace research data objects
  def traject_indexer
    @traject_indexer ||= Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Rails.root.join('app', 'lib', 'dataspace_research_data_config.rb'))
    end
  end

  def self.index(options)
    # content_to_index = TODO
    puts "Indexing with options #{options}"
    i = Indexer.new(options)
    # i.index
    i
  end
end
