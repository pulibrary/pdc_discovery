# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety
# rubocop:disable Metrics/ModuleLength
module ApplicationHelper
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
  def render_field_row_many(title, values, show_always = false)
    return if values.blank?
    values_encoded = values.map { |v| html_escape(v) }
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title.pluralize(values.count)}</span></th>
      <td><span>#{values_encoded.join(', ')}</span></td>
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

  # Outputs the HTML to render a single value as an HTML table row with a search link
  def render_field_row_search_link(title, value, field, show_always = false)
    return if value.blank?
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title}</span></th>
      <td><span>#{link_to(value, "/?f[#{field}][]=#{CGI.escape(value)}&q=&search_field=all_fields")}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render a single value as an HTML table row with a search link
  def render_field_row_search_links(title, values, field, show_always = false)
    return if values.blank?
    css_class = show_always ? "" : "toggable-row hidden-row"
    links = values.map do |value|
      "<span>" + link_to(value, "/?f[#{field}][]=#{CGI.escape(value)}&q=&search_field=all_fields") + "</span>"
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

  # Outputs the HTML to render a list of subjects
  # (this is used on the sidebar)
  def render_subject_search_links(title, values, field)
    return if values.count.zero?
    # Must use <divs> instead of <spans> for them to wrap inside the sidebar
    links_html = values.map do |value|
      "#{link_to(value, "/?f[#{field}][]=#{CGI.escape(value)}&q=&search_field=all_fields", class: 'badge badge-dark sidebar-value-badge', title: value)}<br/>"
    end

    html = <<-HTML
    <tr>
      <th scope="row" class="sidebar-label"><span>#{title}: </span></th>
      <td>#{links_html.join(' ')}</td>
    </tr>
    HTML
    html.html_safe
  end

  def render_globus_download(uri)
    return if uri.blank?
    html = <<-HTML
    <div id="globus">
      <button data-v-b7851b04="" type="button" class="document-downloads__button lux-button solid medium">
        #{link_to('Download from Globus', uri, target: '_blank', title: 'opens in a new tab', rel: 'noopener noreferrer')}
        <i class="bi bi-cloud-arrow-down-fill"></i>
      </button>
    </div>
    HTML
    html.html_safe
  end
end
# rubocop:enable Rails/OutputSafety
# rubocop:enable Metrics/ModuleLength
