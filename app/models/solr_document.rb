# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marc_ss
  extension_parameters[:marc_format_type] = :marcxml
  use_extension(Blacklight::Solr::Document::Marc) do |document|
    document.key?(SolrDocument.extension_parameters[:marc_source_field])
  end

  field_semantics.merge!(
    title: 'title_ssm',
    author: 'author_ssm',
    language: 'language_ssim',
    format: 'format'
  )

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  ABSTRACT_FIELD = 'abstract_tsim'
  DESCRIPTION_FIELD = 'description_tsim'
  ISSUED_DATE_FIELD = 'issue_date_ssim'
  METHODS_FIELD = 'methods_tsim'
  TITLE_FIELD = 'title_tsim'

  def titles
    fetch(TITLE_FIELD, [])
  end

  def title
    titles.first
  end

  def authors
    fetch('author_tesim', [])
  end

  def contributors
    fetch("contributor_tsim", [])
  end

  def issued_dates
    fetch(ISSUED_DATE_FIELD, [])
  end

  def issued_date
    issued_dates.first
  end

  def abstracts
    fetch(ABSTRACT_FIELD, [])
  end

  def abstract
    abstracts.first
  end

  def descriptions
    fetch(DESCRIPTION_FIELD, [])
  end

  def description
    descriptions.first
  end

  def methods
    fetch(METHODS_FIELD, [])
  end

  def files
    files ||= begin
      data = JSON.parse(fetch("files_ss", "[]"))
      data.sort_by { |file| (file["sequence"] || "").to_i }
    end
  end

  def referenced_by
    fetch("referenced_by_ssim", [])
  end
end
