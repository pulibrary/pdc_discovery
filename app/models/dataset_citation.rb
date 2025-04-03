# frozen_string_literal: true

# Handles citations for datasets
# rubocop:disable Metrics/ParameterLists
# rubocop:disable Metrics/ClassLength
# rubocop:disable Style/NumericPredicate
# rubocop:disable Style/IfUnlessModifier
class DatasetCitation
  NEWLINE_INDENTED = "\r\n\t\t\t\t\t\t\t\t"

  # @param authors [<String>] Array of authors.
  # @param years [<String>] Array of years (expected 1 or 2 values).
  # @param title [String>] Title of the dataset
  # @param type [String] Type of the dataset (e.g. "Data set" or "Unpublished raw data")
  # @publisher [String] Publisher of the dataset
  # @doi [String] DOI URL
  def initialize(authors, years, title, type, publisher, doi, version)
    @authors = authors || []
    @years = years || []
    @title = title
    @type = type
    @publisher = publisher
    @doi = doi
    @version = version
  end

  def to_s(style)
    if style == "BibTeX"
      bibtex
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
    apa_version = apa_version_text(@version)
    apa_publisher = append_dot(@publisher)
    apa_doi = @doi

    tokens = [append_dot(apa_author), append_dot(apa_year), apa_title, apa_version, apa_publisher, apa_doi].reject(&:blank?)
    tokens.join(' ')
  rescue => ex
    Rails.logger.error "Error generating APA citation for (#{@title}): #{ex.message}"
    nil
  end

  def apa_version_text(version)
    if version.blank?
      ""
    else
      "Version #{version}."
    end
  end

  # Returns a string with BibTeX citation for the dataset.
  #
  # There is no set standard for datasets and therefore the format we produce
  # was put together from a variety of sources including mimicking what Zotero
  # does and looking at examples from Zenodo (e.g. https://zenodo.org/record/6062882/export/hx#.Yiejad9OnUL)
  #
  # Notice that we use the @electronic{...} identifier instead of @dataset{...} since
  # Zotero does not recognize the later.
  # rubocop:disable Metrics/PerceivedComplexity
  def bibtex
    tokens = []
    if @authors.count > 0
      tokens << bibtex_field_author('author', @authors)
    end

    if @title.present?
      tokens << bibtex_field('title', @title, '{{', '}}')
    end

    if @version.present?
      tokens << bibtex_field('version', @version)
    end

    if @publisher.present?
      tokens << bibtex_field('publisher', @publisher, '{{', '}}')
    end

    if @years.count > 0
      tokens << bibtex_field('year', @years.first)
    end

    if @doi.present?
      tokens << bibtex_field('url', @doi, '{', '}')
    end

    text = "@electronic{#{bibtex_id},\r\n"
    text += tokens.map { |token| "\t#{token}" }.join(",\r\n") + "\r\n"
    text += "}"
    text
  rescue => ex
    Rails.logger.error "Error generating BibTex citation for (#{@title}): #{ex.message}"
    nil
  end
  # rubocop:enable Metrics/PerceivedComplexity

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
  def bibtex_lines(string, max_length = 40)
    string = string.to_s # handles non-string values gracefully
    lines = []
    until string.nil?
      # TODO: it would be nice it we break on spaces rather than in the middle of a word.
      lines << string[0..max_length - 1]
      string = string[max_length..-1]
    end
    lines
  end

  # Creates a line to represent a BibTex field.
  # Breaks long lines into smaller lines.
  # Examples:
  #
  #     field_name = {{ short value }}
  #     field_name = {{ very very very
  #                 very very very very
  #                 long value }}
  #
  def bibtex_field(name, value, open_tag = '', close_tag = '')
    value_trim = bibtex_lines(value).join(NEWLINE_INDENTED)
    name.ljust(12) + '= ' + open_tag + value_trim + close_tag
  end

  # Creates a line to represent multiple authors in a BibTex field
  # https://en.wikibooks.org/wiki/LaTeX/Bibliography_Management#Authors
  #
  # Example:
  #
  #     author = { author1 and
  #              author2 and
  #              author3 }
  #
  def bibtex_field_author(name, authors, open_tag = '{', close_tag = '}')
    value_trim = authors.join(" and #{NEWLINE_INDENTED}")
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
