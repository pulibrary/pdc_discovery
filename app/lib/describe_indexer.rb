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
    pathname = ::Rails.root.join('config', 'traject', "pdc_describe_indexing_config.rb")
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
    parsed = JSON.parse(json)

    puts parsed["resource"]["doi"]
    if parsed["resource"]["doi"].include?("n42z-hb72")
      puts "truncating file list"
      parsed["files"] = []
    end

    byebug

    # This line takes ~2 minutes for the huge dataset
    xml = parsed.to_xml

    doc = Nokogiri::XML(xml)
    collection_node = doc.at('group')
    cdata = Nokogiri::XML::CDATA.new(doc, json)   # 13_880_264 (13 MB) for the huge dataset
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

  def client
    @client ||= Blacklight.default_index.connection
  end

  def delete!(query:)
    client.delete_by_query(query)
    client.commit
    client.optimize
    client
  end

private

  def rss_http_response
    URI.open(@rss_url)
  end

  def rss_xml_doc
    Nokogiri::XML(rss_http_response)
  end

  def rss_url_nodes
    rss_xml_doc.xpath("//item/url/text()")
  end

  def rss_url_list
    rss_url_nodes.map(&:to_s)
  end

  ##
  # Parse the rss_url, get a JSON resource url for each item, convert it to XML, and pass it to traject
  def perform_indexing
    urls_to_retry = []
    rss_url_list.each do |url|
      process_url(url)
    rescue
      urls_to_retry << url
    end

    # retry an errored urls a second time and send error only if they don't work a second time
    urls_to_retry.each do |url|
      process_url(url)
    rescue => ex
      Rails.logger.warn "Error importing record from #{url}. Exception: #{ex.message}"
      Honeybadger.notify "Error importing record from #{url}. Exception: #{ex.message}"
    end
  end

  def process_url(url)
    # Only process to record for now:
    #
    #   small: https://pdc-describe-prod.princeton.edu/describe/works/349.json DOI: 10.34770/jmx2-4219
    #   huge.: https://pdc-describe-prod.princeton.edu/describe/works/470.json DOI: /n42z-hb72
    #
    # The huge dataset has 60K files.
    if url != "https://pdc-describe-prod.princeton.edu/describe/works/470.json" &&
      url != "https://pdc-describe-prod.princeton.edu/describe/works/349.json"
      puts "SKIP: #{url}"
      return
    end
    puts "PROCESS: #{url}"
    # Bumping the timeout because fetching record https://pdc-describe-prod.princeton.edu/describe/works/470.json
    # (which has 60K files) takes more than 30 seconds.
    uri = URI.open(url, open_timeout: 60, read_timeout: 60)
    resource_json = uri.read
    resource_xml = prep_for_indexing(resource_json)
    traject_indexer.process(resource_xml)
    Rails.logger.info "Successfully imported record from #{url}."
  end
end
