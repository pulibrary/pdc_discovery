# frozen_string_literal: true

require 'faraday_middleware'
require 'traject'
require 'open-uri'

##
# Index JSON resource records from PDC Describe to solr
class DescribeIndexer
  ##
  #
  def initialize(rss_url:)
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
  # Parse the rss_url, get a JSON resource url for each item, convert it to XML, and pass it to traject
  def index
    doc = Nokogiri::XML(URI.open(@rss_url))
    url_list = doc.xpath("//item/url/text()").map(&:to_s)
    url_list.each do |url|
      resource_json = URI.open(url).read
      resource_xml = JSON.parse(resource_json).to_xml
      traject_indexer.process(resource_xml)
    end
  end
end
