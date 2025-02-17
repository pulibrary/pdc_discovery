# frozen_string_literal: true
module Indexing
  class ImportHelper
    def self.uri_with_prefix(prefix, value)
      return nil if value.blank?
      "#{prefix}/#{value}"
    end

    def self.doi_uri(value)
      uri_with_prefix("https://doi.org", value)
    end

    def self.ark_uri(value)
      uri_with_prefix("http://arks.princeton.edu", value)
    end

    # Returns true if a record already exists in Solr for the given URIs
    # and that record was imported from PDC Describe.
    def self.pdc_describe_match?(solr_url, uris)
      ark_uri = uris.find { |uri| uri.text.start_with?("http://arks.princeton.edu/ark:/") }&.text
      return true if pdc_describe_match_by_uri?(solr_url, ark_uri)

      doi_uri = uris.find { |uri| uri.text.start_with?("https://doi.org/10.34770/") }&.text
      return true if pdc_describe_match_by_uri?(solr_url, doi_uri)

      false
    end

    # Returns true if a record already exists in Solr for the given URI
    # and that record was imported from PDC Describe.
    def self.pdc_describe_match_by_uri?(solr_url, uri)
      return false if uri.nil?
      solr_query = File.join(solr_url, "select?q=data_source_ssi:pdc_describe+AND+uri_ssim:\"#{uri}\"")
      response = HTTParty.get(solr_query)
      response.parsed_response["response"]["numFound"] != 0
    rescue Errno::ECONNREFUSED => connection_error
      error_message = "HTTP GET request failed for #{solr_query}: #{connection_error}"
      Rails.logger.error(error_message)
      Honeybadger.notify(error_message)
      false
    end

    # Returns the URI to access the folder in Globus where the data is stored for the given file
    def self.globus_folder_uri_from_file(filename)
      origin_id = Rails.configuration.pdc_discovery.globus_collection_uuid
      file_path = File.dirname(filename)
      origin_path = CGI.escape("/#{file_path}/")
      "https://app.globus.org/file-manager?origin_id=#{origin_id}&origin_path=#{origin_path}"
    end
  end
end
