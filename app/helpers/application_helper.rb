# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety
# rubocop:disable Metrics/ModuleLength
module ApplicationHelper
  # This application is deployed in a subdirectory ("/discovery")
  # in staging and production. We control this by setting
  # Rails.application.config.assets.prefix. This method reads
  # that Rails setting and extracts the prefix needed in order for
  # application links to work as expected.
  # @return [String]
  def subdirectory_for_links
    (Rails.application.config.assets.prefix.split("/") - ["assets"]).join("/")
  end

  # Outputs the HTML to render a single value as an HTML table row
  # to be displayed on the metadata section of the show page.
  def render_field_row(title, value, show_always = false)
    return if value.nil?
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title}</span></th>
      <td><span>#{html_escape(value)}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render multiple values as an HTML table row
  def render_field_row_many(title, values, show_always = false, separator = ', ')
    return if values.blank?
    values_encoded = values.map { |v| html_escape(v) }
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title.pluralize(values.count)}</span></th>
      <td><span>#{values_encoded.join(separator)}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render a single value as an HTML table row with a link
  def render_field_row_link(title, url, show_always = false)
    return if url.blank?
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title}</span></th>
      <td><span>#{link_to(url, url, target: '_blank', rel: 'noopener noreferrer')}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  def search_link(value, field)
    "#{subdirectory_for_links}/?f[#{field}][]=#{CGI.escape(value)}&q=&search_field=all_fields"
  end

  # Outputs the HTML to render a single value as an HTML table row with a search link
  def render_field_row_search_link(title, value, field, show_always = false)
    return if value.blank?
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title}</span></th>
      <td><span>#{link_to(value, search_link(value, field))}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render a single value as an HTML table row with a search link
  def render_field_row_search_links(title, values, field, show_always = false)
    return if values.blank?
    css_class = show_always ? "" : "toggable-row hidden-row"
    links = values.map do |value|
      "<span>" + link_to(value, search_link(value, field)) + "</span>"
    end
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title.pluralize(values.count)}</span></th>
      <td>#{links.join(', ')}</td>
    </tr>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render a single value as an HTML table row
  # to be displayed on the sidebar.
  def render_sidebar_row(title, value)
    return if value.nil?
    html = <<-HTML
    <tr>
      <th scope="row" class="sidebar-label"><span>#{title}</span></th>
      <td class="sidebar-value"><span>#{html_escape(value)}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render the DOI as an HTML table row to be
  # displayed on the sidebar with a copy to clipboard button next to it.
  def render_sidebar_doi_row(url, value)
    return if url.nil?
    tooltip = "Copy DOI URL to the clipboard"
    html = <<-HTML
    <tr>
      <th scope="row" class="sidebar-label"><span>DOI:</span></th>
      <td class="sidebar-value">
        <span>#{link_to(value, url, target: '_blank', rel: 'noopener noreferrer')}</span>
        <button id="copy-doi" class="btn btn-sm" data-url="#{url}" title="#{tooltip}">
          <i id="copy-doi-icon" class="bi bi-clipboard" title="#{tooltip}"></i>
          <span id="copy-doi-label" class="copy-doi-label-normal">COPY</span>
        </button>
      </td>
    </tr>
    HTML
    html.html_safe
  end

  def render_sidebar_licenses(licenses)
    return if licenses.count.zero?

    licenses_html = licenses.map do |license|
      url = License.url(license)
      if url.nil?
        "<span>#{html_escape(license)}</span>"
      else
        "<span>" + link_to(license, url, target: '_blank', rel: 'noopener noreferrer') + "</span>"
      end
    end

    html = <<-HTML
    <tr>
      <th scope="row" class="sidebar-label"><span>#{'License'.pluralize(licenses.count)}:</span></th>
      <td class="sidebar-value">#{licenses_html.join('<br/>')}</td>
    </tr>
    HTML
    html.html_safe
  end

  # Renders citation information APA-ish and BibTeX.
  # Notice that the only the APA style is visible, the BibTeX citataion is enabled via JavaScript.
  def render_cite_as(document)
    return if document.cite("APA").nil?

    apa = document.cite("APA")
    bibtex = document.cite("BibTeX")
    bibtex_html = html_escape(bibtex).gsub("\r\n", "<br/>").gsub("\t", "  ").gsub("  ", "&nbsp;&nbsp;")
    bibtex_text = html_escape(bibtex).gsub("\t", "  ")

    html = <<-HTML
      <div class="citation-apa-container">
        <div class="apa-citation">#{html_escape(apa)}</div>
        <button id="copy-apa-citation-button" class="copy-citation-button btn btn-sm" data-style="APA" data-text="#{html_escape(apa)}" title="Copy citation to the clipboard">
          <i class="bi bi-clipboard" title="Copy citation to the clipboard"></i>
          <span class="copy-citation-label-normal">COPY</span>
        </button>
      </div>
      <div class="citation-bibtex-container hidden-element">
        <div class="bibtex-citation">#{bibtex_html}</div>
        <button id="copy-bibtext-citation-button" class="copy-citation-button btn btn-sm" data-style="BibTeX" data-text="#{bibtex_text}" title="Copy BibTeX citation to the clipboard">
          <i class="bi bi-clipboard" title="Copy BibTeX citation to the clipboard"></i>
          <span class="copy-citation-label-normal">COPY</span>
        </button>
        <button id="download-bibtex" class="btn btn-sm" data-url="#{catalog_bibtex_url(id: document.id)}" title="Download BibTeX citation to a file">
          <i class="bi bi-file-arrow-down" title="Download BibTeX citation to a file"></i>
          <span class="copy-citation-label-normal">DOWNLOAD</span>
        </button>
      </div>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render a list of subjects
  # (this is used on the sidebar)
  def render_subject_search_links(title, values, field)
    return if values.count.zero?
    # Must use <divs> instead of <spans> for them to wrap inside the sidebar
    links_html = values.map do |value|
      "#{link_to(value, search_link(value, field), class: 'badge badge-dark sidebar-value-badge', title: value)}<br/>"
    end

    html = <<-HTML
    <tr>
      <th scope="row" class="sidebar-label"><span>#{title}: </span></th>
      <td>#{links_html.join(' ')}</td>
    </tr>
    HTML
    html.html_safe
  end

  def render_globus_download(uri, item_id)
    return if uri.nil?
    html = <<-HTML
    <div id="globus">
      <button data-v-b7851b04="" type="button" class="document-downloads__button lux-button solid medium">
        #{link_to('Download from Globus', uri, target: '_blank', title: 'opens in a new tab', rel: 'noopener noreferrer', class: 'globus-download-link', data: { item_id: item_id })}
        <i class="bi bi-cloud-arrow-down-fill"></i>
      </button>
    </div>
    HTML
    html.html_safe
  end

  def render_empty_files
    html = <<-HTML
    <div id="no_files">
    </div>
    HTML
    html.html_safe
  end

  def authors_search_results_helper(field)
    field[:value].join("; ")
  end

  def render_author(name, add_separator)
    return if name.blank?

    icon_html = '<i class="bi bi-person-fill"></i>'
    separator = add_separator ? ";" : ""
    name_html = "#{name}#{separator}"
    if name == 'Koeser, Rebecca Sutton'
      # Hard-coded for now to demo how researchers with ORCiD will display
      icon_html = '<img alt="ORCID logo" src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" width="16" height="16" />'
      name_html = '<a href="https://orcid.org/0000-0002-8762-8057" target="_blank">' + name + '</a>' + separator
    end

    html = <<-HTML
    <span class="author-name">
      #{icon_html}
      #{name_html}
    </span>
    HTML
    html.html_safe
  end
end
# rubocop:enable Rails/OutputSafety
# rubocop:enable Metrics/ModuleLength
