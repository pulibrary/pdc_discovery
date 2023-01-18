# frozen_string_literal: true

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

  # Returns true if a record already exists in Solr with this ARK as one of the URIs
  # and that record was imported from PDC Describe.
  def self.pdc_describe_match_found?(ark_uri)
    return false if ark_uri.nil?
    solr_query = "#{Blacklight.default_index.connection.uri}select?q=data_source_ssi:pdc_describe+AND+uri_ssim:#{ark_uri}"
    response = HTTParty.get(solr_query)
    response.parsed_response["response"]["numFound"] != 0
  end
end
