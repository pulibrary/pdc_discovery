# frozen_string_literal: true

class DocumentExport
  attr_reader :id, :title, :files, :description, :abstract

  def initialize(solr_document)
    @id = solr_document.id
    @title = solr_document.title
    @files = solr_document.files
    @description = solr_document.description
    @abstract = solr_document.abstract
  end
end
