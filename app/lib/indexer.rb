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
    doc = Nokogiri::XML(@dspace_xml)
    doc.xpath('/items/item').each do |item|
      record = Traject::NokogiriReader.new(item.to_xml, traject_indexer.settings).to_a.first
      traject_indexer.process_record(record)
    end
    traject_indexer.complete
  end

  def output_hash
    traject_indexer.map_record(foo.to_a.first)
  end

  ##
  # Load the traject indexing config for DataSpace research data objects
  def traject_indexer
    @traject_indexer ||= Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Rails.root.join('app', 'lib', 'dataspace_research_data_config.rb'))
    end
  end
end
