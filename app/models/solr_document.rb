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

  # rubocop:disable Lint/UselessAssignment
  def files
    files ||= begin
      data = JSON.parse(fetch("files_ss", "[]"))
      data.sort_by { |file| (file["sequence"] || "").to_i }
    end
  end
  # rubocop:enable Lint/UselessAssignment

  def referenced_by
    fetch("referenced_by_ssim", [])
  end

  def uri
    fetch("uri_tesim", [])
  end

  def format
    fetch("format_ssim", [])
  end

  def extent
    fetch("extent_ssim", [])
  end

  def medium
    fetch("medium_ssim", [])
  end

  def mimetype
    fetch("mimetype_ssim", [])
  end

  def language
    fetch("language_ssim", [])
  end

  def publisher
    fetch("publisher_ssim", [])
  end

  def publisher_place
    fetch("publisher_place_ssim", [])
  end

  def publisher_corporate
    fetch("publisher_corporate_ssim", [])
  end

  def relation
    fetch("relation_ssim", [])
  end

  def relation_is_format_of
    fetch("relation_is_format_of_ssim", [])
  end

  def relation_is_part_of
    fetch("relation_is_part_of_ssim", [])
  end

  def relation_is_part_of_series
    fetch("relation_is_part_of_series_ssim", [])
  end

  def relation_has_part
    fetch("relation_has_part_ssim", [])
  end

  def relation_is_version_of
    fetch("relation_is_version_of_ssim", [])
  end

  def relation_has_version
    fetch("relation_has_version_ssim", [])
  end

  def relation_is_based_on
    fetch("relation_is_based_on_ssim", [])
  end

  def relation_is_referenced_by
    fetch("relation_is_referenced_by_ssim", [])
  end

  def relation_requires
    fetch("relation_requires_ssim", [])
  end

  def relation_replaces
    fetch("relation_replaces_ssim", [])
  end

  def relation_is_replaced_by
    fetch("relation_is_replaced_by_ssim", [])
  end

  def relation_uri
    fetch("relation_uri_ssim", [])
  end

  def rights
    fetch("rights_ssim", [])
  end

  def rights_uri
    fetch("rights_uri_ssim", [])
  end

  def rights_holder
    fetch("rights_holder_ssim", [])
  end

  def subject
    fetch("subject_tesim", [])
  end

  def subject_classification
    fetch("subject_classification_tesim", [])
  end

  def subject_ddc
    fetch("subject_ddc_tesim", [])
  end

  def subject_lcc
    fetch("subject_lcc_tesim", [])
  end

  def subject_lcsh
    fetch("subject_lcsh_tesim", [])
  end

  def subject_mesh
    fetch("subject_mesh_tesim", [])
  end

  def subject_other
    fetch("subject_other_tesim", [])
  end

  def alternative_title
    fetch("alternative_title_ssim", [])
  end

  def genre
    fetch("genre_ssim", [])
  end

  def peer_review_status
    fetch("peer_review_status_ssim", [])
  end

  def alternative_title
    fetch("alternative_title_ssim", [])
  end

  def translator
    fetch("translator_ssim", [])
  end

  def isan
    fetch("isan_ssim", [])
  end




end
