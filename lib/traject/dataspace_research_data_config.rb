# frozen_string_literal: true

require 'logger'
require 'traject'
require 'traject/nokogiri_reader'
require 'blacklight'
require_relative './domain'
require_relative './import_helper'
require_relative './solr_cloud_helper'

settings do
  provide 'solr.url', SolrCloudHelper.collection_writer_url
  provide 'reader_class_name', 'Traject::NokogiriReader'
  provide 'solr_writer.commit_on_close', 'true'
  provide 'repository', ENV['REPOSITORY_ID']
  provide 'logger', Logger.new($stderr, level: Logger::ERROR)
  provide "nokogiri.each_record_xpath", "//items/item"
  provide "dataspace_communities", DataspaceCommunities.new('./spec/fixtures/files/dataspace_communities.json')
end

each_record do |record, context|
  uris = record.xpath("/item/metadata/key[text()='dc.identifier.uri']/../value")
  next unless ImportHelper.pdc_describe_match?(settings["solr.url"], uris)
  id = record.xpath('/item/id')
  Rails.logger.info "Skipping DataSpace record #{id} - already imported from PDC Describe"
  context.skip!("Skipping DataSpace record #{id} - already imported from PDC Describe")
end

# ==================
# Main fields

to_field 'abstract_tsim', extract_xpath("/item/metadata/key[text()='dc.description.abstract']/../value")
to_field 'abstract_tsim', extract_xpath("/item/metadata/key[text()='dcterms.abstract']/../value")
to_field 'creator_tesim', extract_xpath("/item/metadata/key[text()='dcterms.creator']/../value")
to_field 'contributor_tsim', extract_xpath("/item/metadata/key[text()='dc.contributor']/../value")
to_field 'contributor_tsim', extract_xpath("/item/metadata/key[text()='dcterms.contributor']/../value")
to_field 'description_tsim', extract_xpath("/item/metadata/key[text()='dc.description']/../value")
to_field 'description_tsim', extract_xpath("/item/metadata/key[text()='dcterms.description']/../value")
to_field 'handle_ssim', extract_xpath('/item/handle')
to_field 'id', extract_xpath('/item/id')
to_field 'uri_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.uri']/../value")
to_field 'collection_id_ssi', extract_xpath('/item/parentCollection/id')
to_field 'handle_ssi', extract_xpath('/item/handle')

# Track the source of this record
to_field 'data_source_ssi' do |_record, accumulator, _c|
  accumulator.concat ["dataspace"]
end

# ==================
# Community and Collections fields
# Communities can be nested. We gather the community name, the name of the "root" community for the community,
# and the full path (including nested communities) to the community.
#
# Fields communities_ssim and subcommunities_ssim represent the new structure that we
# are moving to for this information as we migrate from DataSpace to PDC Describe.

to_field ['community_name_ssi','communities_ssim'] do |record, accumulator, _c|
  # We are assuming the largest ID represents the parent community in the tree hierarchy
  # (i.e. grandparent nodes were created first and have smaller IDs)
  community_id = record.xpath("/item/parentCommunityList/id").map(&:text).map(&:to_i).sort.last
  community = settings["dataspace_communities"].find_by_id(community_id)
  accumulator.concat [community&.name]
end

to_field ['subcommunity_name_ssi','subcommunities_ssim'] do |record, accumulator, _c|
  community_id = record.xpath("/item/parentCommunityList/id").map(&:text).map(&:to_i).sort.last
  community = settings["dataspace_communities"].find_by_id(community_id)
  if !community.nil? && community.parent_id
    # We only populate this value for subcommunities
    accumulator.concat [community.name]
  end
end

to_field 'community_root_name_ssi' do |record, accumulator, _c|
  community_id = record.xpath("/item/parentCommunityList/id").map(&:text).map(&:to_i).sort.last
  root_name = settings["dataspace_communities"].find_root_name(community_id)
  accumulator.concat [root_name]
end

to_field 'community_path_name_ssi' do |record, accumulator, _c|
  community_id = record.xpath("/item/parentCommunityList/id").map(&:text).map(&:to_i).sort.last
  path_name = settings["dataspace_communities"].find_path_name(community_id).join("|")
  accumulator.concat [path_name]
end

# collection_name_ssi (single value) is the legacy field from DataSpace records
# collection_tag_ssim (multi value) is the new field for DataSpace + PDC Describe records
to_field ['collection_name_ssi', 'collection_tag_ssim'] do |record, accumulator, _c|
  collection_name = record.xpath("/item/parentCollection/name").map(&:text).first
  accumulator.concat [collection_name]
end

# ==================
# author fields

to_field 'author_tesim', extract_xpath("/item/metadata/key[text()='dc.contributor.author']/../value")

# single value is used for sorting
to_field 'author_si' do |record, accumulator, _c|
  values = record.xpath("/item/metadata/key[text()='dc.contributor.author']/../value").map(&:text)
  accumulator.concat [values.uniq.sort.first]
end

# all values as strings for faceting
to_field 'author_ssim' do |record, accumulator, _c|
  values = record.xpath("/item/metadata/key[text()='dc.contributor.author']/../value").map(&:text)
  accumulator.concat values.uniq
end

# ==================
# title fields

to_field 'title_tesim', extract_xpath('/item/name')
to_field 'title_tesim', extract_xpath("/item/metadata/key[text()='dcterms.title']/../value")

to_field 'title_si' do |record, accumulator, _c|
  values = []
  values += record.xpath('/item/name').map(&:text)
  values += record.xpath("/item/metadata/key[text()='dcterms.title']/../value").map(&:text)
  accumulator.concat [values.uniq.first]
end

to_field 'alternative_title_tesim', extract_xpath("/item/metadata/key[text()='dc.title.alternative']/../value")
to_field 'alternative_title_tesim', extract_xpath("/item/metadata/key[text()='dcterms.alternative']/../value")

# ==================
# Calculate domain from the communities
# Notice that we expect only one domain from DSpace records but the field
# is multi-value because PDC Describe supports more than one domain.
to_field 'domain_ssim' do |record, accumulator, _context|
  communities = record.xpath("/item/parentCommunityList/type[text()='community']/../name").map(&:text)
  domains = Domain.from_communities(communities)
  if domains.count > 1
    id = record.xpath('/item/id/text()')
    logger.warn "Multiple domains detected for record: #{id}, using only the first one."
  end
  accumulator.concat [domains.first]
end

# ==================
# contributor fields

to_field 'advisor_tesim', extract_xpath("/item/metadata/key[text()='dc.contributor.advisor']/../value")
to_field 'editor_tesim', extract_xpath("/item/metadata/key[text()='dc.contributor.editor']/../value")
to_field 'illustrator_tesim', extract_xpath("/item/metadata/key[text()='dc.contributor.illustrator']/../value")
to_field 'other_contributor_tsim', extract_xpath("/item/metadata/key[text()='dc.contributor.other']/../value")
to_field 'creator_tesim', extract_xpath("/item/metadata/key[text()='dc.creator']/../value")

# ==================
# coverage fields

to_field 'spatial_coverage_tesim', extract_xpath("/item/metadata/key[text()='dc.coverage.spatial']/../value")
to_field 'spatial_coverage_tesim', extract_xpath("/item/metadata/key[text()='dcterms.spatial']/../value")
to_field 'temporal_coverage_tesim', extract_xpath("/item/metadata/key[text()='dc.coverage.temporal']/../value")
to_field 'temporal_coverage_tesim', extract_xpath("/item/metadata/key[text()='dcterms.temporal']/../value")
to_field 'coverage_tesim', extract_xpath("/item/metadata/key[text()='dcterms.coverage']/../value")

# ==================
# date fields

to_field "date_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dcterms.date']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_accessioned_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.accessioned']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_available_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.available']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "year_available_itsi" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.available']/../value").map(&:text)
  accumulator.concat [DateNormalizer.years_from_dates(dates).first]
end

to_field "date_created_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.created']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_created_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dcterms.created']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_submitted_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.submitted']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_submitted_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dcterms.dateSubmitted']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_modified_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dcterms.modified']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "issue_date_ssim" do |record, accumulator, _context|
  issue_dates = record.xpath("/item/metadata/key[text()='dc.date.issued']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(issue_dates)
end

to_field "issue_date_ssim" do |record, accumulator, _context|
  issue_dates = record.xpath("/item/metadata/key[text()='dcterms.issued']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(issue_dates)
end

# Date in yyyy-mm-dd format so we can sort by it
to_field "issue_date_strict_ssi" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.issued']/../value").map(&:text)
  dates += record.xpath("/item/metadata/key[text()='dcterms.issued']/../value").map(&:text)
  accumulator.concat [DateNormalizer.strict_dates(dates).first]
end

to_field "date_accepted_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dcterms.dateAccepted']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "copyright_date_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.copyright']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "copyright_date_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dcterms.dateCopyrighted']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_valid_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dcterms.valid']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

# ==================
# description fields

to_field 'provenance_ssim', extract_xpath("/item/metadata/key[text()='dc.description.provenance']/../value")
to_field 'provenance_ssim', extract_xpath("/item/metadata/key[text()='dcterms.provenance']/../value")
to_field 'sponsorship_ssim', extract_xpath("/item/metadata/key[text()='dc.description.sponsorship']/../value")
to_field 'statementofresponsibility_ssim', extract_xpath("/item/metadata/key[text()='dc.description.statementofresponsibility']/../value")
to_field 'tableofcontents_tesim', extract_xpath("/item/metadata/key[text()='dc.description.tableofcontents']/../value")
to_field 'tableofcontents_tesim', extract_xpath("/item/metadata/key[text()='dcterms.tableOfContents']/../value")
to_field 'description_uri_ssim', extract_xpath("/item/metadata/key[text()='dc.description.uri']/../value")

# ==================
# identifier fields

to_field 'other_identifier_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier']/../value")
to_field 'other_identifier_ssim', extract_xpath("/item/metadata/key[text()='dcterms.identifier']/../value")
to_field 'citation_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.citation']/../value")
to_field 'govdoc_id_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.govdoc']/../value")
to_field 'isan_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.isan']/../value")
to_field 'isbn_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.isbn']/../value")
to_field 'issn_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.issn']/../value")
to_field 'sici_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.sici']/../value")
to_field 'ismn_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.ismn']/../value")
to_field 'local_id_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.other']/../value")

# ==================
# Indexing the URL for now. We might need to index to a more complex structure if we want to store
# more than just the URL (e.g. a title or the language)
#
# TODO: What should we do with values that don't start with HTTP
# (e.g. doi:10.1088/0029-5515/57/1/016034 in document id: 84912)?
# Should we fix them before we index them?
to_field 'referenced_by_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isreferencedby']/../value")
to_field 'referenced_by_ssim', extract_xpath("/item/metadata/key[text()='dcterms.references']/../value")

# ==================
# format fields
to_field 'format_ssim', extract_xpath("/item/metadata/key[text()='dc.format']/../value")
to_field 'format_ssim', extract_xpath("/item/metadata/key[text()='dcterms.format']/../value")
to_field 'extent_ssim', extract_xpath("/item/metadata/key[text()='dc.format.extent']/../value")
to_field 'extent_ssim', extract_xpath("/item/metadata/key[text()='dcterms.extent']/../value")
to_field 'medium_ssim', extract_xpath("/item/metadata/key[text()='dc.format.medium']/../value")
to_field 'medium_ssim', extract_xpath("/item/metadata/key[text()='dcterms.medium']/../value")
to_field 'mimetype_ssim', extract_xpath("/item/metadata/key[text()='dc.format.mimetype']/../value")

# ==================
# language fields
to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dc.language']/../value")
to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dcterms.language']/../value")
to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dc.language.iso']/../value")
to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dc.language.rfc3066']/../value")

# ==================
# publisher fields
to_field 'publisher_ssim', extract_xpath("/item/metadata/key[text()='dc.publisher']/../value")
to_field 'publisher_ssim', extract_xpath("/item/metadata/key[text()='dcterms.publisher']/../value")
to_field 'publisher_place_ssim', extract_xpath("/item/metadata/key[text()='dc.publisher.place']/../value")
to_field 'publisher_corporate_ssim', extract_xpath("/item/metadata/key[text()='dc.publisher.corporate']/../value")

# ==================
# relation fields
to_field 'relation_ssim', extract_xpath("/item/metadata/key[text()='dc.relation']/../value")
to_field 'relation_ssim', extract_xpath("/item/metadata/key[text()='dcterms.relation']/../value")
to_field 'relation_is_format_of_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isformatof']/../value")
to_field 'relation_is_format_of_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isFormatOf']/../value")
to_field 'relation_has_format_ssim', extract_xpath("/item/metadata/key[text()='dcterms.hasFormat']/../value")
to_field 'relation_is_part_of_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.ispartof']/../value")
to_field 'relation_is_part_of_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isPartOf']/../value")
to_field 'relation_is_part_of_series_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.ispartofseries']/../value")
to_field 'relation_has_part_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.haspart']/../value")
to_field 'relation_has_part_ssim', extract_xpath("/item/metadata/key[text()='dcterms.hasPart']/../value")
to_field 'relation_is_version_of_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isversionof']/../value")
to_field 'relation_is_version_of_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isVersionOf']/../value")
to_field 'relation_has_version_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.hasversion']/../value")
to_field 'relation_has_version_ssim', extract_xpath("/item/metadata/key[text()='dcterms.hasVersion']/../value")
to_field 'relation_is_based_on_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isbasedon']/../value")
to_field 'relation_is_referenced_by_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isreferencedby']/../value")
to_field 'relation_is_referenced_by_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isReferencedBy']/../value")
to_field 'relation_requires_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.requires']/../value")
to_field 'relation_requires_ssim', extract_xpath("/item/metadata/key[text()='dcterms.requires']/../value")
to_field 'relation_is_required_by_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isRequiredBy']/../value")
to_field 'relation_replaces_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.replaces']/../value")
to_field 'relation_replaces_ssim', extract_xpath("/item/metadata/key[text()='dcterms.replaces']/../value")
to_field 'relation_is_replaced_by_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isreplacedby']/../value")
to_field 'relation_is_replaced_by_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isReplacedBy']/../value")
to_field 'relation_uri_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.uri']/../value")

# ==================
# rights fields
to_field 'rights_ssim', extract_xpath("/item/metadata/key[text()='dc.rights']/../value")
to_field 'rights_ssim', extract_xpath("/item/metadata/key[text()='dcterms.rights']/../value")
to_field 'rights_uri_ssim', extract_xpath("/item/metadata/key[text()='dc.rights.uri']/../value")
to_field 'rights_holder_ssim', extract_xpath("/item/metadata/key[text()='dc.rights.holder']/../value")
to_field 'rights_holder_ssim', extract_xpath("/item/metadata/key[text()='dcterms.rightsHolder']/../value")
to_field 'access_rights_ssim', extract_xpath("/item/metadata/key[text()='dc.rights.accessRights']/../value")
to_field 'access_rights_ssim', extract_xpath("/item/metadata/key[text()='dcterms.accessRights']/../value")
to_field 'license_ssim', extract_xpath("/item/metadata/key[text()='dc.rights.license']/../value")
to_field 'license_ssim', extract_xpath("/item/metadata/key[text()='dcterms.license']/../value")

# ==================
# subject fields
to_field 'subject_tesim', extract_xpath("/item/metadata/key[text()='dc.subject']/../value")
to_field 'subject_tesim', extract_xpath("/item/metadata/key[text()='dcterms.subject']/../value")
to_field 'subject_classification_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.classification']/../value")
to_field 'subject_ddc_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.ddc']/../value")
to_field 'subject_lcc_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.lcc']/../value")
to_field 'subject_lcsh_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.lcsh']/../value")
to_field 'subject_mesh_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.mesh']/../value")
to_field 'subject_other_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.other']/../value")

# subject_all_ssim is used for faceting (must be string)
# subject_all_tesim is used for searching (use text english)
to_field ['subject_all_ssim', 'subject_all_tesim'] do |record, accumulator, _context|
  xpaths = []
  xpaths << "/item/metadata/key[text()='dc.subject']/../value"
  xpaths << "/item/metadata/key[text()='dcterms.subject']/../value"
  xpaths << "/item/metadata/key[text()='dc.subject.classification']/../value"
  xpaths << "/item/metadata/key[text()='dc.subject.ddc']/../value"
  xpaths << "/item/metadata/key[text()='dc.subject.lcc']/../value"
  xpaths << "/item/metadata/key[text()='dc.subject.lcsh']/../value"
  xpaths << "/item/metadata/key[text()='dc.subject.mesh']/../value"
  xpaths << "/item/metadata/key[text()='dc.subject.other']/../value"

  values = []
  xpaths.each do |xpath|
    values += record.xpath(xpath).map(&:text)
  end

  accumulator.concat values.uniq
end

# ==================
# genre, provenance, peer review fields
to_field 'genre_ssim', extract_xpath("/item/metadata/key[text()='dc.type']/../value")
to_field 'genre_ssim', extract_xpath("/item/metadata/key[text()='dcterms.type']/../value")
to_field 'provenance_ssim', extract_xpath("/item/metadata/key[text()='dc.provenance']/../value")
to_field 'peer_review_status_ssim', extract_xpath("/item/metadata/key[text()='dc.description.version']/../value")

# ==================
# contributor fields
to_field 'translator_ssim', extract_xpath("/item/metadata/key[text()='dc.contributor.translator']/../value")
to_field 'funding_agency_ssim', extract_xpath("/item/metadata/key[text()='dc.contributor.funder']/../value")

# ==================
# accrual fields
to_field 'accrual_method_ssim', extract_xpath("/item/metadata/key[text()='dcterms.accrualMethod']/../value")
to_field 'accrual_periodicity_ssim', extract_xpath("/item/metadata/key[text()='dcterms.accrualPeriodicity']/../value")
to_field 'accrual_policy_ssim', extract_xpath("/item/metadata/key[text()='dcterms.accrualPolicy']/../value")

# ==================
# audience and citation fields
to_field 'audience_ssim', extract_xpath("/item/metadata/key[text()='dcterms.audience']/../value")
to_field 'available_ssim', extract_xpath("/item/metadata/key[text()='dcterms.available']/../value")
to_field 'bibliographic_citation_ssim', extract_xpath("/item/metadata/key[text()='dcterms.bibliographicCitation']/../value")
to_field 'conforms_to_ssim', extract_xpath("/item/metadata/key[text()='dcterms.comformsTo']/../value")

# ==================
# other dcterm fields
to_field 'education_level_ssim', extract_xpath("/item/metadata/key[text()='dcterms.educationLevel']/../value")
to_field 'instructional_method_ssim', extract_xpath("/item/metadata/key[text()='dcterms.instructionalMethod']/../value")
to_field 'mediator_ssim', extract_xpath("/item/metadata/key[text()='dcterms.mediator']/../value")
to_field 'source_ssim', extract_xpath("/item/metadata/key[text()='dcterms.source']/../value")

# ==================
# Store all files metadata as a single JSON string so that we can display detailed information for each of them.
to_field 'files_ss' do |record, accumulator, _context|
  dataspace_handle = record.xpath('/item/handle/text()').text
  bitstreams = record.xpath("/item/bitstreams").map do |node|
    {
      name: node.xpath("name").text,
      description: node.xpath("description").text,
      format: node.xpath("format").text,
      size: node.xpath("sizeBytes").text,
      mime_type: node.xpath("mimeType").text,
      sequence: node.xpath("sequenceId").text,
      bundle_name: node.xpath("bundleName").text,
      handle: dataspace_handle
    }
  end

  # Only files in the ORIGINAL bundle in DataSpace need to be indexed,
  # the rest are files that have been deleted or have purposes outside
  # of PDC Discovery (e.g. extracted text).
  #
  # We also explicitly exclude DSpace license.txt file since it's a DSpace
  # generated file and we don't want it in PDC Discovery.
  bitstreams.reject! do |bitstream|
    bitstream[:bundle_name] != "ORIGINAL" || bitstream[:name] == "license.txt"
  end

  accumulator.concat [bitstreams.to_json.to_s]
end

# Indexes the entire text in a catch-all field.
to_field 'all_text_teimv' do |record, accumulator, _context|
  all_text = record.xpath("//text()").map(&:to_s).join(" ")
  accumulator.concat [all_text]
end
