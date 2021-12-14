# frozen_string_literal: true
module RecentlyAddedHelper
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
  def render_recent_entry(entry)
    html = <<-HTML
    <li id="recently-added-#{entry.id}">
    <span class="genre"><i id="#{entry.id}" class="bi #{ICONS[entry.genre&.downcase].presence || 'bi-file-earmark-fill'}"></i>#{html_escape(entry.genre)}</span>
    <span class="title">#{link_to(html_escape(entry.title), html_escape(entry.id))}</span>
    <span class="credit">Published on #{html_escape(entry.issued_date)}, #{html_escape(entry.authors.join(', '))}</span>
    </li>
    HTML
    html.html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
