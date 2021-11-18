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
end
