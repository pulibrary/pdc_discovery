# frozen_string_literal: true

module ApplicationHelper
  def render_document_heading; end

  # Outputs the HTML to render a single value as an HTML table row
  # rubocop:disable Rails/OutputSafety
  def render_field_row(title, value, render_empty: false)
    return if value.nil?
    return if value.empty? && render_empty == false
    value_encoded = html_escape(value)
    html = <<-HTML
    <tr>
      <th scope="row"><span>#{title}</span></th>
      <td><span>#{value_encoded}</span></td>
    </tr>
    HTML
    html.html_safe
  end
  # rubocop:enable Rails/OutputSafety

  # Outputs the HTML to render a single value as an HTML table row with a link
  # rubocop:disable Rails/OutputSafety
  def render_field_row_link(title, url)
    return if url.blank?
    html = <<-HTML
    <tr>
      <th scope="row"><span>#{title}</span></th>
      <td><span>#{link_to(url, url, target: '_blank', rel: 'noopener noreferrer')}</span></td>
    </tr>
    HTML
    html.html_safe
  end
  # rubocop:enable Rails/OutputSafety

  # rubocop:disable Rails/OutputSafety
  def render_globus_download(uri)
    return if uri.blank?
    html = <<-HTML
    <div id="globus">
      <button data-v-b7851b04="" type="button" class="document-downloads__button lux-button solid medium">#{link_to('Download from Globus', uri, target: '_blank', title: 'opens in a new tab', rel: 'noopener noreferrer')}
        <svg data-v-b7851b04="" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16" class="bi bi-cloud-arrow-down-fill">
          <path data-v-b7851b04="" d="M8 2a5.53 5.53 0 0 0-3.594 1.342c-.766.66-1.321 1.52-1.464 2.383C1.266 6.095 0 7.555 0 9.318 0 11.366 1.708 13 3.781 13h8.906C14.502 13 16 11.57 16 9.773c0-1.636-1.242-2.969-2.834-3.194C12.923 3.999 10.69 2 8 2zm2.354 6.854-2 2a.5.5 0 0 1-.708 0l-2-2a.5.5 0 1 1 .708-.708L7.5 9.293V5.5a.5.5 0 0 1 1 0v3.793l1.146-1.147a.5.5 0 0 1 .708.708z"></path>
        </svg>
      </button>
    </div>
    HTML
    html.html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
