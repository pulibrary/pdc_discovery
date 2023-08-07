# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class SolrDocument
  include Blacklight::Solr::Document
  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marc_ss
  extension_parameters[:marc_format_type] = :marcxml
  use_extension(Blacklight::Solr::Document::Marc) do |document|
    document.key?(SolrDocument.extension_parameters[:marc_source_field])
  end

  field_semantics.merge!(
    title: 'title_tesim',
    contributor: 'author_tesim',
    format: 'genre_ssim',
    date: 'issue_date_ssim'
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
  TITLE_FIELD = 'title_tesim'

  # These icons map to CSS classes in Bootstrap
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

  # .*?\s is lazy match so the regex stop as soon as space is found
  GLOBUS_URI_REGEX = /.*(https\:\/\/app.globus.org\/file-manager.*?\s).*/.freeze

  def id
    fetch('id')
  end

  def titles
    fetch(TITLE_FIELD, [])
  end

  def title
    titles.first
  end

  # Returns the list of author names (ordered if possible)
  def authors
    authors_ordered.map(&:value)
  end

  # Returns the list of authors with all their information including
  # name, ORCID, and affiliation. List is ordered if possible.
  def authors_ordered
    @authors_ordered ||= begin
      authors_json = fetch('authors_json_ss', nil)
      if authors_json
        # PDC Describe records contain this field;
        # get the author data and sort it.
        authors = JSON.parse(authors_json).map { |hash| Author.new(hash) }
        authors.sort_by(&:sequence)
      else
        # DataSpace record don't contain this field;
        # do the best we can with author_tesim value.
        names = fetch('author_tesim', [])
        names.map { |name| Author.new({ "value" => name }) }
      end
    end
  end

  # Returns a string with the authors and shortens it if there are more than 2 authors.
  # https://owl.purdue.edu/owl/research_and_citation/apa_style/apa_formatting_and_style_guide/in_text_citations_author_authors.html
  def authors_et_al
    authors_all = authors
    if authors_all.count <= 2
      authors_all.join(" & ")
    else
      authors_all.first + " et al."
    end
  end

  # Create an author hash when we only have an author name (e.g. for records coming from DataSpace)
  # In this case order/sequence cannot be determined.
  def author_from_name(name)
    {
      "value" => name,
      "name_type" => "Personal",
      "given_name" => nil,
      "family_name" => nil,
      "identifier" => nil,
      "affiliations" => [],
      "sequence" => 0
    }
  end

  def creators
    fetch('creator_tesim', [])
  end

  def community_path
    communities.first
  end

  def communities
    fetch("communities_ssim", [])
  end

  def subcommunities
    fetch("subcommunities_ssim", [])
  end

  def collection_name
    fetch("collection_name_ssi", "")
  end

  def collection_tags
    fetch("collection_tag_ssim", [])
  end

  def contributors
    fetch("contributor_tsim", [])
  end

  def accessioned_dates
    fetch("date_accessioned_ssim", [])
  end

  def accessioned_date
    accessioned_dates.first
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

  def data_source
    fetch("data_source_ssi", "dataspace")
  end

  def files
    @files ||= begin
      data = JSON.parse(fetch("files_ss", "[]"))
      data.map { |file| DatasetFile.from_hash(file, data_source) }.sort_by(&:sequence)
    end
  end

  # Returns an array with the counts by file extension
  # e.g. [{extension: "txt", file_count: 3}, {extension: "csv", file_count: 1}]
  def file_counts
    groups = files.group_by(&:extension)
    groups.map { |key, value| { extension: key, file_count: value.count } }.sort_by { |group| -group[:file_count] }
  end

  def table_of_contents
    fetch("tableofcontents_tesim", [])
  end

  def referenced_by
    fetch("referenced_by_ssim", [])
  end

  def uri
    fetch("uri_ssim", [])
  end

  def doi_url
    uri.each do |link|
      return link if link.downcase.start_with?('https://doi.org/')
    end
    nil
  end

  def doi_value
    doi_url&.gsub('https://doi.org/', '')
  end

  def format
    fetch("format_ssim", [])
  end

  def globus_uri
    # First we try to use the value indexed (only exists for PDC Describe records)
    indexed_uri = fetch("globus_uri_ssi", nil)
    return indexed_uri unless indexed_uri.nil?

    # ...then check the links indexed to see if one of them looks like a Globus URI
    uri.each do |link|
      return link if link.downcase.start_with?('https://app.globus.org/')
    end

    # ...if all fails, see if there is a Globus URI in the description
    globus_uri_from_description
  end

  def globus_uri_from_description
    match = description&.match(GLOBUS_URI_REGEX)
    return match.captures.first.strip if match
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

  def relation_has_format
    fetch("relation_has_format_ssim", [])
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

  def relation_is_required_by
    fetch("relation_is_required_by_ssim", [])
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

  # For PDC Describe records we have a single value for the name and the uri
  # and we can safely assume they are related.
  def rights_name_and_uri
    name = fetch("rights_name_ssi", nil)
    uri = fetch("rights_uri_ssi", nil)
    return nil if name.nil? || uri.nil?
    { name: name, uri: uri }
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
    fetch("alternative_title_tesim", [])
  end

  def genres
    fetch("genre_ssim", []).sort
  end

  # Sometimes we need a single genre for an item, even though an item may have more than one.
  # This method makes sure we always get the same value (the first one from a sorted list).
  def genre
    genres.first
  end

  def peer_review_status
    fetch("peer_review_status_ssim", [])
  end

  def translator
    fetch("translator_ssim", [])
  end

  def isan
    fetch("isan_ssim", [])
  end

  def access_rights
    fetch("access_rights_ssim", [])
  end

  def funding_agency
    fetch("funding_agency_ssim", [])
  end

  def provenance
    fetch("provenance_ssim", [])
  end

  def license
    fetch("license_ssim", [])
  end

  def accrual_method
    fetch("accrual_method_ssim", [])
  end

  def accrual_periodicity
    fetch("accrual_periodicity_ssim", [])
  end

  def accrual_policy
    fetch("accrual_policy_ssim", [])
  end

  def audience
    fetch("audience_ssim", [])
  end

  def available
    fetch("available_ssim", [])
  end

  def bibliographic_citation
    fetch("bibliographic_citation_ssim", [])
  end

  def conforms_to
    fetch("conforms_to_ssim", [])
  end

  def coverage
    fetch("coverage_tesim", [])
  end

  def spatial_coverage
    fetch("spatial_coverage_tesim", [])
  end

  def temporal_coverage
    fetch("temporal_coverage_tesim", [])
  end

  def dates_created
    fetch("date_created_ssim", [])
  end

  def date_created
    dates_created.first
  end

  def dates_submitted
    fetch("date_submitted_ssim", [])
  end

  def date_submitted
    dates_submitted.first
  end

  def dates_accepted
    fetch("date_accepted_ssim", [])
  end

  def date_accepted
    dates_accepted.first
  end

  def dates_copyrighted
    fetch("copyright_date_ssim", [])
  end

  def date_copyrighted
    dates_copyrighted.first
  end

  def dates_modified
    fetch("date_modified_ssim", [])
  end

  def date_modified
    dates_modified.first
  end

  def dates_valid
    fetch("date_valid_ssim", [])
  end

  def education_level
    fetch("education_level_ssim", [])
  end

  def other_identifier
    fetch("other_identifier_ssim", [])
  end

  def instructional_method
    fetch("instructional_method_ssim", [])
  end

  def mediator
    fetch("mediator_ssim", [])
  end

  def source
    fetch("source_ssim", [])
  end

  def domains
    fetch("domain_ssim", "")
  end

  def icon_css
    ICONS[genre&.downcase] || 'bi-file-earmark-fill'
  end

  # Returns a DatasetCitation object for the current document
  def citation
    @citation ||= begin
      year_available = fetch('year_available_itsi', nil)
      years = year_available ? [year_available.to_s] : []
      DatasetCitation.new(authors, years, title, 'Data set', publisher.first, doi_url)
    end
  end

  # Returns a string with the indicated citation style (e.g. APA or BibTeX)
  def cite(style)
    citation.to_s(style)
  end

  # Returns the ID for a BibTeX citation for this document.
  # rubocop:disable Rails/Delegate
  def bibtex_id
    citation.bibtex_id
  end
  # rubocop:enable Rails/Delegate
end
# rubocop:enable Metrics/ClassLength
