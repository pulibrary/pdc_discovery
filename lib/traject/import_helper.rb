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
end
