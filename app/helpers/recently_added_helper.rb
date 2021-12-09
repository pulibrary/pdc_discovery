# frozen_string_literal: true
module RecentlyAddedHelper
  require 'net/http'
  require 'json'

  ICONS = {
    "dataset" => "bi-stack",
    "moving image" => "bi-film",
    "software" => "bi-code-slash",
    "image" => "bi-image",
    "text" => "bi-card-text",
    "collection" => "bi-collection-fill",
    "article" => "bi-journal-text",
    "interactive resource" => "bi-pc-display-horizontal"
  }.freeze

  # Outputs the HTML to render recent entries as list items
  # rubocop:disable Rails/OutputSafety
  def render_recent_entry(entry_key, entry_values)
    return if entry_values.empty?
    html = <<-HTML
    <li id="recently-added-#{entry_key}">
    <span class="genre"><i id="#{entry_key}" class="bi #{ICONS[entry_values[:genre].downcase].presence || 'bi-file-earmark-fill'}"></i>#{html_escape(entry_values[:genre])}</span>
    <span class="title">#{link_to(html_escape(entry_values[:title]), html_escape(entry_values[:link]))}</span>
    <span class="credit">Posted on #{html_escape(entry_values[:issue_date])}, #{html_escape(entry_values[:author])}</span>
    </li>
    HTML
    html.html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
