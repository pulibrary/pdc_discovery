# frozen_string_literal: true

xml.item do
  xml.title(document_presenter(document).heading || (document.to_semantic_values[:title].first if document.to_semantic_values.key?(:title)))
  xml.link(polymorphic_url(search_state.url_for_document(document)))
  xml.author(document.to_semantic_values[:author].first) if document.to_semantic_values.key? :author
  xml.genre(document.to_semantic_values[:genre].first) if document.to_semantic_values.key? :genre
  xml.issue_date(document.to_semantic_values[:issue_date].first) if document.to_semantic_values.key? :issue_date
end
