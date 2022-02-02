# frozen_string_literal: true

# Handles citations for datasets
# rubocop:disable Metrics/ParameterLists
class DatasetCitation
  def self.styles
    ["APA", "Chicago"]
  end

  # @param authors [<String>] Array of authors.
  # @param years [<String>] Array of years (expected 1 or 2 values).
  # @param title [String>] Title of the dataset
  # @param type [String] Type of the dataset (e.g. "Data set" or "Unpublished raw data")
  # @publisher [String] Publisher of the dataset
  # @doi [String] DOI URL
  def initialize(authors, years, title, type, publisher, doi)
    @authors = authors || []
    @years = years || []
    @title = title
    @type = type
    @publisher = publisher
    @doi = doi
  end

  def to_s(style)
    if style == "Chicago"
      chicago
    else
      apa
    end
  end

  # Returns a string with APA citation for the dataset
  # Reference: https://libguides.usc.edu/APA7th/datasets#s-lg-box-22855503
  def apa
    apa_author = ''
    case @authors.count
    when 0
      # do nothing
    when 1
      apa_author += @authors.first
    when 2
      apa_author += @authors.join(' & ')
    else
      apa_author += @authors[0..-2].join(', ') + ', & ' + @authors[-1]
    end

    apa_year = ''
    case @years.count
    when 0
      # do nothing
    when 1
      apa_year += "(#{@years.first})"
    else
      apa_year += "(#{@years.join('-')})"
    end

    apa_title = DatasetCitation.custom_strip(@title)
    apa_title += " [#{@type}]" if @type.present?
    apa_title = append_dot(apa_title)

    apa_publisher = append_dot(@publisher)
    apa_doi = @doi

    tokens = [append_dot(apa_author), append_dot(apa_year), apa_title, apa_publisher, apa_doi].reject(&:blank?)
    tokens.join(' ')
  rescue => ex
    Rails.logger.error "Error generating APA citation for (#{@title}): #{ex.message}"
    nil
  end

  # Returns a string with Chicago citation for the dataset
  # Reference: https://libguides.webster.edu/data/chicago
  def chicago
    chi_author = ''
    case @authors.count
    when 0
      # do nothing
    when 1
      chi_author += @authors.first
    when 2
      chi_author += @authors.join(' and ')
    else
      chi_author += @authors[0..-2].join(', ') + ' and ' + @authors[-1]
    end

    chi_year = @years.count.zero? ? '' : append_dot(@years.join('-'))

    chi_title = append_dot(@title)
    chi_publisher = append_dot(@publisher)
    chi_doi = append_dot(@doi)

    tokens = [append_dot(chi_author), chi_title, chi_year, chi_publisher, chi_doi].reject(&:blank?)
    tokens.join(' ')
  rescue => ex
    Rails.logger.error "Error generating Chicago citation for (#{@title}): #{ex.message}"
    nil
  end

  # Appends a dot to a string if it does not end with one.
  def append_dot(value)
    return nil if value.nil?
    return '' if value.empty?
    DatasetCitation.custom_strip(value) + '.'
  end

  # Strip a few specific characters that tend to mess up citations (e.g. trailing periods, commas, et cetera)
  def self.custom_strip(value)
    return nil if value.nil?
    return '' if value.empty?
    while true
      last_char = value[-1]
      break if last_char.nil? || !last_char.in?('. ,')
      value = value.chomp(last_char)
    end
    value
  end
end
# rubocop:enable Metrics/ParameterLists
