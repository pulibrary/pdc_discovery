# frozen_string_literal: true

require 'faraday_middleware'
require 'traject'

##
# Index DSpace objects to solr
class DspaceIndexer
  REST_LIMIT = 100

  ##
  # @param [String] XML from DSpace rest interface
  def initialize(dspace_xml)
    @dspace_xml = dspace_xml
  end

  ##
  # Index XML as received from DSpace
  def index
    traject_indexer.process(@dspace_xml)
    traject_indexer.complete
  end

  def research_data_config_path
    pathname = ::Rails.root.join('lib', 'traject', "dataspace_research_data_config.rb")
    pathname.to_s
  end

  ##
  # Load the traject indexing config for DataSpace research data objects
  def traject_indexer
    @traject_indexer ||= Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(research_data_config_path)
    end
  end

  ##
  # TODO: Pass in indexing options from the command line
  # Convenience method for kicking off indexing
  # @example DspaceIndexer.index(collection_handle: '88435/dsp015m60qr913')
  def self.index(_options)
    server = "#{Rails.configuration.pdc_discovery.dataspace_url}/rest"
    collection_id = '261'
    url = "#{server}/collections/#{collection_id}/items?limit=#{REST_LIMIT}&offset=0&expand=all"

    resp = Faraday.get(url, {}, { 'Accept': 'application/xml' })
    i = DspaceIndexer.new(resp.body)
    i.index
    i
  end
end
