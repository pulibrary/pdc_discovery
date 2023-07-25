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
  end

  # Calculates the display filename for a PDC Describe file.
  # PDC Describe files are prefixed with DOI + database_id, for example "10.123/4567/40/folder1/filename1.txt"
  # (where 40 is the database id).
  # This method strips the DOI and the database ID from the path so that we display a friendly
  # path to the user, e.g. "folder1/filename1.txt".
  def self.display_filename(full_path, doi)
    display_filename = nil
    if doi.present? && full_path.start_with?(doi)
      # drop the DOI
      filename_no_doi = full_path[doi.length..-1]
      db_id = filename_no_doi.match(/\/\d+\//).to_s
      # drop the database ID
      display_filename = filename_no_doi[db_id.length..-1] unless db_id.empty?
    end
    display_filename || full_path
  end
end
