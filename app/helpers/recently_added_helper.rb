# frozen_string_literal: true
module RecentlyAddedHelper
  # Outputs the HTML to render recent entries as list items
  # rubocop:disable Rails/OutputSafety
  def render_recent_entry(entry)
    html = <<-HTML
    <li id="recently-added-#{entry.id}">
    <span class="genre"><i id="#{entry.id}" class="bi #{entry.icon_css}"></i>#{html_escape(entry.genre)}</span>
    <span class="title">#{link_to(html_escape(entry.title), solr_document_path(entry.id))}</span>
    <span class="credit">Published #{html_escape(entry.issued_date)}, #{html_escape(entry.authors_et_al)}</span>
    </li>
    HTML
    html.html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
