# frozen_string_literal: true

require 'logger'
require 'traject'
require 'traject/nokogiri_reader'
require 'blacklight'
require_relative './import_helper'
require_relative './solr_cloud_helper'

##
# If you need to debug PDC Describe indexing, change the log level to Logger::DEBUG
settings do
  provide 'solr.url', SolrCloudHelper.collection_writer_url
  provide 'reader_class_name', 'Traject::NokogiriReader'
  provide 'solr_writer.commit_on_close', 'true'
  provide 'repository', ENV['REPOSITORY_ID']
  provide 'logger', Logger.new($stderr, level: Logger::WARN)
end

# ==================
# Main fields

to_field 'id' do |record, accumulator, _c|
  raw_doi = record.xpath("/hash/resource/doi/text()").to_s
  munged_doi = "doi-" + raw_doi.tr('/', '-').tr('.', '-')
  # TODO: remove this after testing
  puts "sleeping"
  sleep(1)
  puts "awaken"
  munged_doi = "doi-" + raw_doi.tr('/', '-').tr('.', '-') + '-' + Time.now.seconds_since_midnight.to_i.to_s
  # ===================
  accumulator.concat [munged_doi]
end

# the <pdc_describe_json> element contains a CDATA node with a JSON blob in it
to_field 'pdc_describe_json_ss' do |record, accumulator, _c|
  datacite = record.xpath("/hash/pdc_describe_json/text()").first.content
  accumulator.concat [datacite]
end

# Track the source of this record
to_field 'data_source_ssi' do |_record, accumulator, _c|
  accumulator.concat ["pdc_describe"]
end

# to_field 'abstract_tsim', extract_xpath("/item/metadata/key[text()='dcterms.abstract']/../value")
# to_field 'creator_tesim', extract_xpath("/item/metadata/key[text()='dcterms.creator']/../value")
to_field 'contributor_tsim' do |record, accumulator, _c|
  contributor_names = record.xpath("/hash/resource/contributors/contributor/value").map(&:text)
  accumulator.concat contributor_names
end
to_field 'description_tsim', extract_xpath("/hash/resource/description")
# to_field 'handle_ssim', extract_xpath('/item/handle')
to_field 'uri_ssim' do |record, accumulator, _c|
  doi = ImportHelper.doi_uri(record.xpath("/hash/resource/doi").text)
  ark = ImportHelper.ark_uri(record.xpath("/hash/resource/ark").text)
  accumulator.concat [doi, ark].compact
end

# ==================
# Community and Collections fields
# These fields mimic the DataSpace data and will eventually be retired.
to_field 'community_name_ssi', extract_xpath("/hash/group/title")
to_field 'community_root_name_ssi', extract_xpath("/hash/group/title")
to_field 'community_path_name_ssi', extract_xpath("/hash/group/title")

# These fields use the new PDC Describe structure (notice that they are multi-value)
to_field 'communities_ssim', extract_xpath("/hash/resource/communities/community")
to_field 'subcommunities_ssim', extract_xpath("/hash/resource/subcommunities/subcommunity")

# ==================
# Collection tags
# There is no equivalent in DataSpace.
to_field 'collection_tag_ssim' do |record, accumulator, _c|
  collection_tags = record.xpath("/hash/resource/collection-tags/collection-tag").map(&:text)
  accumulator.concat collection_tags
end

# ==================
# Group in PDC Describe, e.g. Research data or PPPL
# There is no equivalent in DataSpace.
to_field 'group_title_ssi', extract_xpath("/hash/group/title")
to_field 'group_code_ssi', extract_xpath("/hash/group/code")

# ==================
# author fields
to_field 'author_tesim' do |record, accumulator, _c|
  author_names = record.xpath("/hash/resource/creators/creator/value").map(&:text)
  accumulator.concat author_names
end

# single value is used for sorting
to_field 'author_si' do |record, accumulator, _c|
  author_names = record.xpath("/hash/resource/creators/creator/value").map(&:text)
  accumulator.concat [author_names.uniq.sort.first]
end

# all values as strings for faceting
# TODO: Should we include contributors here since the value is for faceting?
to_field 'author_ssim' do |record, accumulator, _c|
  author_names = record.xpath("/hash/resource/creators/creator/value").map(&:text)
  accumulator.concat author_names
end

# Extract the author data from the pdc_describe_json and save it on its own field as JSON
to_field 'authors_json_ss' do |record, accumulator, _c|
  pdc_json = record.xpath("/hash/pdc_describe_json/text()").first.content
  authors = JSON.parse(pdc_json).dig("resource", "creators") || []
  accumulator.concat [authors.to_json]
end

# ==================
# title fields
to_field 'title_tesim' do |record, accumulator, _c|
  titles = record.xpath('/hash/resource/titles/title').map { |title| title.xpath("./title").text }
  accumulator.concat titles
end

to_field 'title_si' do |record, accumulator, _c|
  main_title = record.xpath('/hash/resource/titles/title').find { |title| title.xpath("./title-type").text == "" }
  accumulator.concat [main_title.xpath("./title").text] unless main_title.nil?
end

to_field 'alternative_title_tesim' do |record, accumulator, _c|
  alternative_titles = record.xpath('/hash/resource/titles/title').select { |title| title.xpath("./title-type").text != "" }
  accumulator.concat alternative_titles.map { |title| title.xpath("./title").text }
end

to_field 'domain_ssim' do |record, accumulator, _context|
  domains = record.xpath("/hash/resource/domains/domain").map(&:text)
  accumulator.concat domains
end

# # ==================
# # contributor fields

# to_field 'advisor_tesim', extract_xpath("/item/metadata/key[text()='dc.contributor.advisor']/../value")
# to_field 'editor_tesim', extract_xpath("/item/metadata/key[text()='dc.contributor.editor']/../value")
# to_field 'illustrator_tesim', extract_xpath("/item/metadata/key[text()='dc.contributor.illustrator']/../value")
# to_field 'other_contributor_tsim', extract_xpath("/item/metadata/key[text()='dc.contributor.other']/../value")
# to_field 'creator_tesim', extract_xpath("/item/metadata/key[text()='dc.creator']/../value")

# # ==================
# # coverage fields

# to_field 'spatial_coverage_tesim', extract_xpath("/item/metadata/key[text()='dc.coverage.spatial']/../value")
# to_field 'temporal_coverage_tesim', extract_xpath("/item/metadata/key[text()='dc.coverage.temporal']/../value")
# to_field 'coverage_tesim', extract_xpath("/item/metadata/key[text()='dcterms.coverage']/../value")

# # ==================
# # date fields

# to_field "date_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dc.date']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "date_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dcterms.date']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "date_accessioned_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dc.date.accessioned']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "date_available_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dc.date.available']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "year_available_itsi" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dc.date.available']/../value").map(&:text)
#   accumulator.concat [DateNormalizer.years_from_dates(dates).first]
# end

# to_field "date_created_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dc.date.created']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "date_created_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dcterms.created']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "date_submitted_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dc.date.submitted']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "date_submitted_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dcterms.dateSubmitted']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "date_modified_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dcterms.modified']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

to_field 'issue_date_ssim', extract_xpath("/hash/resource/publication-year")

# # Date in yyyy-mm-dd format so we can sort by it
# to_field "issue_date_strict_ssi" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dc.date.issued']/../value").map(&:text)
#   dates += record.xpath("/item/metadata/key[text()='dcterms.issued']/../value").map(&:text)
#   accumulator.concat [DateNormalizer.strict_dates(dates).first]
# end

# to_field "date_accepted_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dcterms.dateAccepted']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "copyright_date_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dc.date.copyright']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "copyright_date_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dcterms.dateCopyrighted']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# to_field "date_valid_ssim" do |record, accumulator, _context|
#   dates = record.xpath("/item/metadata/key[text()='dcterms.valid']/../value").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(dates)
# end

# # ==================
# # description fields

# to_field 'provenance_ssim', extract_xpath("/item/metadata/key[text()='dc.description.provenance']/../value")
# to_field 'sponsorship_ssim', extract_xpath("/item/metadata/key[text()='dc.description.sponsorship']/../value")
# to_field 'statementofresponsibility_ssim', extract_xpath("/item/metadata/key[text()='dc.description.statementofresponsibility']/../value")
# to_field 'tableofcontents_tesim', extract_xpath("/item/metadata/key[text()='dc.description.tableofcontents']/../value")
# to_field 'description_uri_ssim', extract_xpath("/item/metadata/key[text()='dc.description.uri']/../value")

# # ==================
# # identifier fields

# to_field 'other_identifier_ssim', extract_xpath("/item/metadata/key[text()='dcterms.identifier']/../value")
# to_field 'citation_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.citation']/../value")
# to_field 'govdoc_id_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.govdoc']/../value")
# to_field 'isan_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.isan']/../value")
# to_field 'isbn_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.isbn']/../value")
# to_field 'issn_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.issn']/../value")
# to_field 'sici_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.sici']/../value")
# to_field 'ismn_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.ismn']/../value")
# to_field 'local_id_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier.other']/../value")

# # ==================
# # Indexing the URL for now. We might need to index to a more complex structure if we want to store
# # more than just the URL (e.g. a title or the language)
# #
# # TODO: What should we do with values that don't start with HTTP
# # (e.g. doi:10.1088/0029-5515/57/1/016034 in document id: 84912)?
# # Should we fix them before we index them?
# to_field 'referenced_by_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isreferencedby']/../value")
# to_field 'referenced_by_ssim', extract_xpath("/item/metadata/key[text()='dcterms.references']/../value")

# ==================
# format fields
# to_field 'format_ssim', extract_xpath("/item/metadata/key[text()='dc.format']/../value")
# to_field 'format_ssim', extract_xpath("/item/metadata/key[text()='dcterms.format']/../value")
# to_field 'extent_ssim', extract_xpath("/item/metadata/key[text()='dc.format.extent']/../value")
# to_field 'extent_ssim', extract_xpath("/item/metadata/key[text()='dcterms.extent']/../value")
# to_field 'medium_ssim', extract_xpath("/item/metadata/key[text()='dc.format.medium']/../value")
# to_field 'medium_ssim', extract_xpath("/item/metadata/key[text()='dcterms.medium']/../value")
# to_field 'mimetype_ssim', extract_xpath("/item/metadata/key[text()='dc.format.mimetype']/../value")

# # ==================
# # language fields
# to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dc.language']/../value")
# to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dcterms.language']/../value")
# to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dc.language.iso']/../value")
# to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dc.language.rfc3066']/../value")

# ==================
# publisher fields
to_field 'publisher_ssim', extract_xpath("/hash/resource/publisher")
# to_field 'publisher_place_ssim', extract_xpath("/item/metadata/key[text()='dc.publisher.place']/../value")
# to_field 'publisher_corporate_ssim', extract_xpath("/item/metadata/key[text()='dc.publisher.corporate']/../value")

# # ==================
# # relation fields
# to_field 'relation_ssim', extract_xpath("/item/metadata/key[text()='dc.relation']/../value")
# to_field 'relation_ssim', extract_xpath("/item/metadata/key[text()='dcterms.relation']/../value")
# to_field 'relation_is_format_of_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isformatof']/../value")
# to_field 'relation_is_format_of_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isFormatOf']/../value")
# to_field 'relation_has_format_ssim', extract_xpath("/item/metadata/key[text()='dcterms.hasFormat']/../value")
# to_field 'relation_is_part_of_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.ispartof']/../value")
# to_field 'relation_is_part_of_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isPartOf']/../value")
# to_field 'relation_is_part_of_series_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.ispartofseries']/../value")
# to_field 'relation_has_part_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.haspart']/../value")
# to_field 'relation_has_part_ssim', extract_xpath("/item/metadata/key[text()='dcterms.hasPart']/../value")
# to_field 'relation_is_version_of_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isversionof']/../value")
# to_field 'relation_is_version_of_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isVersionOf']/../value")
# to_field 'relation_has_version_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.hasversion']/../value")
# to_field 'relation_has_version_ssim', extract_xpath("/item/metadata/key[text()='dcterms.hasVersion']/../value")
# to_field 'relation_is_based_on_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isbasedon']/../value")
# to_field 'relation_is_referenced_by_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isreferencedby']/../value")
# to_field 'relation_is_referenced_by_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isReferencedBy']/../value")
# to_field 'relation_requires_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.requires']/../value")
# to_field 'relation_requires_ssim', extract_xpath("/item/metadata/key[text()='dcterms.requires']/../value")
# to_field 'relation_is_required_by_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isRequiredBy']/../value")
# to_field 'relation_replaces_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.replaces']/../value")
# to_field 'relation_replaces_ssim', extract_xpath("/item/metadata/key[text()='dcterms.replaces']/../value")
# to_field 'relation_is_replaced_by_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isreplacedby']/../value")
# to_field 'relation_is_replaced_by_ssim', extract_xpath("/item/metadata/key[text()='dcterms.isReplacedBy']/../value")
# to_field 'relation_uri_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.uri']/../value")

# # ==================
# # rights fields
to_field 'rights_name_ssi', extract_xpath("/hash/resource/rights/name")
to_field 'rights_uri_ssi', extract_xpath("/hash/resource/rights/uri")

# # ==================
# # subject fields
# to_field 'subject_tesim', extract_xpath("/item/metadata/key[text()='dc.subject']/../value")
# to_field 'subject_tesim', extract_xpath("/item/metadata/key[text()='dcterms.subject']/../value")
# to_field 'subject_classification_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.classification']/../value")
# to_field 'subject_ddc_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.ddc']/../value")
# to_field 'subject_lcc_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.lcc']/../value")
# to_field 'subject_lcsh_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.lcsh']/../value")
# to_field 'subject_mesh_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.mesh']/../value")
# to_field 'subject_other_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.other']/../value")

# subject_all_ssim is used for faceting (must be string)
# subject_all_tesim is used for searching (use text english)
to_field ['subject_all_ssim', 'subject_all_tesim'] do |record, accumulator, _context|
  keywords = record.xpath("/hash/resource/keywords/keyword").map(&:text)
  accumulator.concat keywords
end

# # ==================
# # genre, provenance, peer review fields
to_field 'genre_ssim', extract_xpath("/hash/resource/resource-type")
# to_field 'provenance_ssim', extract_xpath("/item/metadata/key[text()='dc.provenance']/../value")
# to_field 'peer_review_status_ssim', extract_xpath("/item/metadata/key[text()='dc.description.version']/../value")

# # ==================
# # contributor fields
# to_field 'translator_ssim', extract_xpath("/item/metadata/key[text()='dc.contributor.translator']/../value")
# to_field 'funding_agency_ssim', extract_xpath("/item/metadata/key[text()='dc.contributor.funder']/../value")

# ==================
# Funders
# Store all funders as a single JSON string so that we can display detailed information for each of them.
to_field 'funders_ss' do |record, accumulator, _context|
  funders = record.xpath("/hash/resource/funders/funder").map do |funder|
    {
      name: funder.xpath("funder-name").text,
      ror: funder.xpath("ror").text,
      award_number: funder.xpath("award-number").text,
      award_uri: funder.xpath("award-uri").text
    }
  end
  accumulator.concat [funders.to_json.to_s]
end

# # ==================
# # accrual fields
# to_field 'accrual_method_ssim', extract_xpath("/item/metadata/key[text()='dcterms.accrualMethod']/../value")
# to_field 'accrual_periodicity_ssim', extract_xpath("/item/metadata/key[text()='dcterms.accrualPeriodicity']/../value")
# to_field 'accrual_policy_ssim', extract_xpath("/item/metadata/key[text()='dcterms.accrualPolicy']/../value")

# # ==================
# # audience and citation fields
# to_field 'audience_ssim', extract_xpath("/item/metadata/key[text()='dcterms.audience']/../value")
# to_field 'available_ssim', extract_xpath("/item/metadata/key[text()='dcterms.available']/../value")
# to_field 'bibliographic_citation_ssim', extract_xpath("/item/metadata/key[text()='dcterms.bibliographicCitation']/../value")
# to_field 'conforms_to_ssim', extract_xpath("/item/metadata/key[text()='dcterms.comformsTo']/../value")

# # ==================
# # other dcterm fields
# to_field 'education_level_ssim', extract_xpath("/item/metadata/key[text()='dcterms.educationLevel']/../value")
# to_field 'instructional_method_ssim', extract_xpath("/item/metadata/key[text()='dcterms.instructionalMethod']/../value")
# to_field 'mediator_ssim', extract_xpath("/item/metadata/key[text()='dcterms.mediator']/../value")
# to_field 'source_ssim', extract_xpath("/item/metadata/key[text()='dcterms.source']/../value")

# ==================
# Store all files metadata as a single JSON string so that we can display detailed information for each of them.
to_field 'files_ss' do |record, accumulator, _context|
  files = record.xpath("/hash/files/file").map do |file|
    {
      name: File.basename(file.xpath("filename").text),
      size: file.xpath("size").text,
      url: file.xpath('url').text
    }
  end
  accumulator.concat [files.to_json.to_s]
end

# Indexes the entire text in a catch-all field.
to_field 'all_text_teimv' do |record, accumulator, _context|
  accumulator.concat [record.text]
end
