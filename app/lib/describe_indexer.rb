# frozen_string_literal: true

require 'faraday_middleware'
require 'traject'
require 'open-uri'

##
# Fetch an RSS feed of approved works from PDC Describe. For each work, index a PDC Describe JSON resource to solr.
class DescribeIndexer
  ##
  # See config/pdc_discovery.yml for configuration of the RSS feed that
  # this indexer uses to harvest data from PDC Describe.
  # @param [String] rss_url
  def initialize(rss_url: Rails.configuration.pdc_discovery.pdc_describe_rss)
    @rss_url = rss_url
  end

  ##
  # Load the traject indexing config for PDC Describe JSON resources
  def traject_indexer
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(datacite_indexing_config_path)
    end
  end

  def datacite_indexing_config_path
    pathname = ::Rails.root.join('lib', 'traject', "pdc_describe_indexing_config.rb")
    pathname.to_s
  end

  ##
  # Only index if Rails.configuration.pdc_discovery.index_pdc_describe == true
  # See config/pdc_discovery.yml to change this setting for a given environment.
  def index
    if Rails.configuration.pdc_discovery.index_pdc_describe == true
      perform_indexing
    else
      Rails.logger.warn "PDC Describe indexing is not turned on for this environment. See config/pdc_discovery.yml"
    end
  end

  # Given a json document, return an XML string that contains
  # the JSON blob as a CDATA element
  # @param [String] json
  # @return [String]
  def prep_for_indexing(json)
    xml = JSON.parse(json).to_xml
    doc = Nokogiri::XML(xml)
    collection_node = doc.at('collection')
    cdata = Nokogiri::XML::CDATA.new(doc, json)
    collection_node.add_next_sibling("<pdc_describe_json></pdc_describe_json>")
    pdc_describe_json_node = doc.at('pdc_describe_json')
    pdc_describe_json_node.add_child(cdata)
    doc.to_s
  end

  def index_one(json)
    resource_xml = prep_for_indexing(json)
    traject_indexer.process(resource_xml)
    traject_indexer.complete
  end

private

  ##
  # Parse the rss_url, get a JSON resource url for each item, convert it to XML, and pass it to traject
  def perform_indexing
    doc = Nokogiri::XML(URI.open(@rss_url))
    url_list = doc.xpath("//item/url/text()").map(&:to_s)
    url_list.each do |url|
      resource_json = URI.open(url).read
      resource_xml = prep_for_indexing(resource_json)
      traject_indexer.process(resource_xml)
    rescue => ex
      Rails.logger.warn "Error importing record from #{url}. Exception: #{ex.message}"
      Honeybadger.notify "Error importing record from #{url}. Exception: #{ex.message}"
    end
  end
end
