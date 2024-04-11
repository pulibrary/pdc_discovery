# frozen_string_literal: true

class DocumentExport
  attr_reader :id, :title, :files

  def initialize(solr_document)
    @id = solr_document.id
    @title = solr_document.title
    @files = solr_document.files
  end
end
