# frozen_string_literal: true

class DocumentExport
  attr_reader :id, :title, :files, :description, :abstract, :rights, :authors, :doi_value, :doi_url,
    :total_file_size, :embargo_date, :globus_url

  def initialize(solr_document)
    @id = solr_document.id
    @title = solr_document.title
    @files = solr_document.files
    @description = solr_document.description
    @abstract = solr_document.abstract
    @rights = solr_document.rights_enhanced
    @authors = solr_document.authors_ordered
    @doi_value = solr_document.doi_value
    @doi_url = solr_document.doi_url
    @total_file_size = solr_document.total_file_size
    @embargo_date = solr_document.embargo_date
    @globus_url = solr_document.globus_uri
  end
end
