# frozen_string_literal: true

# Handles citations for datasets
# rubocop:disable Metrics/ParameterLists
# rubocop:disable Metrics/ClassLength
# rubocop:disable Style/NumericPredicate
# rubocop:disable Style/IfUnlessModifier
class DatasetCitation
  def self.styles
    ["APA", "BibTeX"]
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
    if style == "BibTeX"
      bibtex
    elsif style == "BibTeX-html"
      bibtex_html
    else
      apa
    end
  end

  # Returns a string with APA-ish citation for the dataset
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

  # Returns a string with BibTex citation for the dataset
  # References:
  #   https://libguides.nps.edu/citation/ieee-bibtex
  #   https://www.citethisforme.com/citation-generator/bibtex
  def bibtex
    tokens = []
    if @authors.count > 0
      # https://en.wikibooks.org/wiki/LaTeX/Bibliography_Management#Authors
      tokens << "author = \"#{@authors.join(' and ')}\""
    end

    if @title.present?
      tokens << "title = \"#{@title}\""
    end

    if @publisher.present?
      tokens << "publisher = \"#{@publisher}\""
    end

    if @years.count > 0
      tokens << "year = \"#{@years.first}\""
    end

    if @doi.present?
      tokens << "url = \"#{@doi}\""
    end

    text = ""
    text += "@electronic{ #{bibtex_id},\r\n"
    text += tokens.map { |token| "  #{token}" }.join(",\r\n") + "\r\n"
    text += "}"
    text
  rescue => ex
    Rails.logger.error "Error generating BibTex citation for (#{@title}): #{ex.message}"
    nil
  end

  def bibtex_html
    tokens = []
    if @authors.count > 0
      # https://en.wikibooks.org/wiki/LaTeX/Bibliography_Management#Authors
      tokens << bibtex_field_multi('author', @authors, '{', '}')
    end

    if @title.present?
      tokens << bibtex_field('title', @title, '{{', '}}')
    end

    if @publisher.present?
      tokens << bibtex_field('publisher', @publisher, '{{', '}}')
    end

    if @years.count > 0
      tokens << bibtex_field('year', @years.first, '', '')
    end

    if @doi.present?
      tokens << bibtex_field('url', @doi, '{', '}')
    end

    text = ""
    text += "@dataset{#{bibtex_id},\r\n"
    text += tokens.map { |token| "  #{token}" }.join(",\r\n") + "\r\n"
    text += "}"
    text
  rescue => ex
    Rails.logger.error "Error generating BibTex citation for (#{@title}): #{ex.message}"
    nil
  end

  # Return a string with the ContextObjects in Spans (COinS) information
  # https://en.wikipedia.org/wiki/COinS
  def coins
    tokens = []
    tokens << "url_ver=Z39.88-2004"
    tokens << "ctx_ver=Z39.88-2004"
    tokens << "rft.type=webpage"
    tokens << "rft_val_fmt=#{CGI.escape('info:ofi/fmt:kev:mtx:dc')}"

    if @title.present?
      tokens << "rft.title=#{CGI.escape(@title)}"
    end

    @authors.each do |author|
      tokens << "rft.au=#{CGI.escape(author)}"
    end

    if @years.count > 0
      tokens << "rft.date=#{CGI.escape(@years.first.to_s)}"
    end

    if @publisher.present?
      tokens << "rft.publisher=#{CGI.escape(@publisher)}"
    end

    if @doi.present?
      tokens << "rft.identifier=#{CGI.escape(@doi)}"
    end

    "<span class=\"Z3988\" title=\"#{tokens.join('&amp;')}\"></span>"
  rescue => ex
    Rails.logger.error "Error generating COinS citation for (#{@title}): #{ex.message}"
    nil
  end

  # Returns an ID value for a BibTex citation
  def bibtex_id
    author_id = 'unknown'
    if @authors.count > 0
      author_id = @authors.first.downcase.tr(' ', '_').gsub(/[^a-z0-9_]/, '')
    end
    year_id = @years.first&.to_s || 'unknown'
    "#{author_id}_#{year_id}"
  end

  # Breaks a string into lines of at most max_length.
  # Returns an array with the lines.
  def bibtex_lines(string, max_length=40)
    lines = []
    while string != nil
      # TODO: it would be nice it we break on spaces rather than at random
      lines << string[0..max_length-1]
      string = string[max_length..-1]
    end
    lines
  end

  def bibtex_field(name, value, open_tag = '', close_tag = '')
    value_trim = bibtex_lines(value).join("\r\n\t\t\t\t\t\t\t\t")
    name.ljust(12) + '= ' + open_tag + value_trim + close_tag
  end

  def bibtex_field_multi(name, values, open_tag = '', close_tag = '')
    value_trim = values.join(" and \r\t\t\t\t\t\t\t\t")
    name.ljust(12) + '= ' + open_tag + value_trim + close_tag
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
# rubocop:enable Metrics/ClassLength
# rubocop:enable Style/NumericPredicate
# rubocop:enable Style/IfUnlessModifier
