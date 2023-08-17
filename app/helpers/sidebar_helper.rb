# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety
module SidebarHelper
  # Outputs the HTML to render the DOI with a copy to clipboard button next to it.
  def render_sidebar_doi_row(url, value)
    return if url.nil?
    tooltip = "Copy DOI URL to the clipboard"
    html = <<-HTML
      <span class="sidebar-header">DOI</span><br/>
      <span class="sidebar-value">#{link_to(value, url, target: '_blank', rel: 'noopener noreferrer')}
        <button id="copy-doi" style="padding-top: 0;" class="btn btn-sm" data-url="#{url}" title="#{tooltip}">
          <i id="copy-doi-icon" class="bi bi-clipboard" title="#{tooltip}"></i>
          <span id="copy-doi-label" class="copy-doi-label-normal">COPY</span>
        </button>
      </span>
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

  # Outputs the HTML to render a list of subjects
  def render_sidebar_subject_search_links(header, values, field)
    return if values.count.zero?

    links_html = values.map do |value|
      link_to(value, search_link(value, field), class: 'badge badge-dark sidebar-value-badge', title: value)
    end.join(" ")

    html = <<-HTML
      <div class="sidebar-row">
        <span class="sidebar-header">#{header}</span><br/>
        <span class="sidebar-value">#{links_html}</span>
      </div>
    HTML
    html.html_safe
  end

  def render_sidebar_value(header, value)
    return if value.nil?
    html = <<-HTML
      <div class="sidebar-row">
        <span class="sidebar-header">#{header}</span><br/>
        <span class="sidebar-value">#{value}</span>
      </div>
    HTML
    html.html_safe
  end

  def render_sidebar_values(header, values, separator = "<br/>")
    return if values.count == 0
    html = <<-HTML
      <div class="sidebar-row">
        <span class="sidebar-header">#{header}</span><br/>
        <span class="sidebar-value">#{values.join(separator)}</span>
      </div>
    HTML
    html.html_safe
  end

  def render_sidebar_related_identifiers(header, identifiers)
    return if identifiers.count == 0

    identifiers_html = identifiers.map do |identifier|
      id = identifier["related_identifier"]
      id_type = identifier["related_identifier_type"]
      type = identifier["relation_type"]&.titleize
      if id.nil? || type.nil?
        nil
      elsif id.start_with?("https://", "http://")
        "#{type} <a href=#{id} target=_blank>#{id}</a>"
      elsif id_type == "DOI"
        "#{type} <a href=https://doi.org/#{id} target=_blank>#{id}</a>"
      else
        "#{type} #{id}"
      end
    end.compact.join("<br/>")

    html = <<-HTML
      <div class="sidebar-row">
        <span class="sidebar-header">#{header}</span><br/>
        <span class="sidebar-value">#{identifiers_html}</span>
      </div>
    HTML
    html.html_safe
  end
end
# rubocop:enable Rails/OutputSafety
