# frozen_string_literal: true

require 'logger'
require 'traject'
require 'traject/nokogiri_reader'
require 'blacklight'

settings do
  provide 'solr.url', Blacklight.default_index.connection.uri.to_s
  provide 'reader_class_name', 'Traject::NokogiriReader'
  provide 'solr_writer.commit_on_close', 'true'
  provide 'repository', ENV['REPOSITORY_ID']
  provide 'logger', Logger.new($stderr, level: Logger::ERROR)
  provide "nokogiri.each_record_xpath", "//items/item"
end

# ==================
# Top level document
# ==================

# ==================
# fields for above the fold single page display

to_field 'abstract_tsim', extract_xpath("/item/metadata/key[text()='dc.description.abstract']/../value")
to_field 'author_tesim', extract_xpath("/item/metadata/key[text()='dc.contributor.author']/../value")
to_field 'contributor_tsim', extract_xpath("/item/metadata/key[text()='dc.contributor']/../value")
to_field 'description_tsim', extract_xpath("/item/metadata/key[text()='dc.description']/../value")
to_field 'handle_ssim', extract_xpath('/item/handle')
to_field 'id', extract_xpath('/item/id')
to_field 'title_ssim', extract_xpath('/item/name')
to_field 'title_tsim', extract_xpath('/item/name')
to_field 'uri_tesim', extract_xpath("/item/metadata/key[text()='dc.identifier.uri']/../value")

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
to_field 'temporal_coverage_tesim', extract_xpath("/item/metadata/key[text()='dc.coverage.temporal']/../value")

# ==================
# date fields

to_field "copyright_date_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.copyright']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date']/../value").map(&:text)
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

to_field "date_created_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.created']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_submitted_ssim" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.submitted']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "issue_date_ssim" do |record, accumulator, _context|
  issue_dates = record.xpath("/item/metadata/key[text()='dc.date.issued']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(issue_dates)
end

# ==================
# description fields

to_field 'provenance_ssim', extract_xpath("/item/metadata/key[text()='dc.description.provenance']/../value")
to_field 'sponsorship_ssim', extract_xpath("/item/metadata/key[text()='dc.description.sponsorship']/../value")
to_field 'statementofresponsibility_ssim', extract_xpath("/item/metadata/key[text()='dc.description.statementofresponsibility']/../value")
to_field 'tableofcontents_tesim', extract_xpath("/item/metadata/key[text()='dc.description.tableofcontents']/../value")
to_field 'description_uri_ssim', extract_xpath("/item/metadata/key[text()='dc.description.uri']/../value")

# ==================
# identifier fields

to_field 'other_identifier_ssim', extract_xpath("/item/metadata/key[text()='dc.identifier']/../value")
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

# ==================
# format fields
to_field 'format_ssim', extract_xpath("/item/metadata/key[text()='dc.format']/../value")
to_field 'extent_ssim', extract_xpath("/item/metadata/key[text()='dc.format.extent']/../value")
to_field 'medium_ssim', extract_xpath("/item/metadata/key[text()='dc.format.medium']/../value")
to_field 'mimetype_ssim', extract_xpath("/item/metadata/key[text()='dc.format.mimetype']/../value")

# ==================
# language fields
to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dc.language']/../value")
to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dc.language.iso']/../value")
to_field 'language_ssim', extract_xpath("/item/metadata/key[text()='dc.language.rfc3066']/../value")


# ==================
# publisher fields
to_field 'publisher_ssim', extract_xpath("/item/metadata/key[text()='dc.publisher']/../value")
to_field 'publisher_place_ssim', extract_xpath("/item/metadata/key[text()='dc.publisher.place']/../value")
to_field 'publisher_corporate_ssim', extract_xpath("/item/metadata/key[text()='dc.publisher.corporate']/../value")

# ==================
# relation fields
to_field 'relation_ssim', extract_xpath("/item/metadata/key[text()='dc.relation']/../value")
to_field 'relation_is_format_of_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isformatof']/../value")
to_field 'relation_is_part_of_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.ispartof']/../value")
to_field 'relation_is_part_of_series_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.ispartofseries']/../value")
to_field 'relation_has_part_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.haspart']/../value")
to_field 'relation_is_version_of_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isversionof']/../value")
to_field 'relation_has_version_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.hasversion']/../value")
to_field 'relation_is_based_on_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isbasedon']/../value")
to_field 'relation_is_referenced_by_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isreferencedby']/../value")
to_field 'relation_requires_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.requires']/../value")
to_field 'relation_replaces_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.replaces']/../value")
to_field 'relation_is_replaced_by_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.isreplacedby']/../value")
to_field 'relation_uri_ssim', extract_xpath("/item/metadata/key[text()='dc.relation.uri']/../value")

# ==================
# rights fields
to_field 'rights_ssim', extract_xpath("/item/metadata/key[text()='dc.rights']/../value")
to_field 'rights_uri_ssim', extract_xpath("/item/metadata/key[text()='dc.rights.uri']/../value")
to_field 'rights_holder_ssim', extract_xpath("/item/metadata/key[text()='dc.rights.holder']/../value")
to_field 'access_rights_ssim', extract_xpath("/item/metadata/key[text()='dc.rights.accessRights']/../value")
to_field 'license_ssim', extract_xpath("/item/metadata/key[text()='dc.rights.license']/../value")

# ==================
# subject fields
to_field 'subject_tesim', extract_xpath("/item/metadata/key[text()='dc.subject']/../value")
to_field 'subject_classification_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.classification']/../value")
to_field 'subject_ddc_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.ddc']/../value")
to_field 'subject_lcc_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.lcc']/../value")
to_field 'subject_lcsh_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.lcsh']/../value")
to_field 'subject_mesh_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.mesh']/../value")
to_field 'subject_other_tesim', extract_xpath("/item/metadata/key[text()='dc.subject.other']/../value")

# ==================
# genre, provenance, peer review, alternative title fields
to_field 'genre_ssim', extract_xpath("/item/metadata/key[text()='dc.type']/../value")
to_field 'provenance_ssim', extract_xpath("/item/metadata/key[text()='dc.provenance']/../value")
to_field 'peer_review_status_ssim', extract_xpath("/item/metadata/key[text()='dc.description.version']/../value")
to_field 'alternative_title_ssim', extract_xpath("/item/metadata/key[text()='dc.title.alternative']/../value")

# ==================
# contributor fields
to_field 'translator_ssim', extract_xpath("/item/metadata/key[text()='dc.contributor.translator']/../value")
to_field 'funding_agency_ssim', extract_xpath("/item/metadata/key[text()='dc.contributor.funder']/../value")

# ==================
# Store all files metadata as a single JSON string so that we can display detailed information for each of them.
to_field 'files_ss' do |record, accumulator, _context|
  bitstreams = record.xpath("/item/bitstreams").map do |node|
    {
      name: node.xpath("name").text,
      format: node.xpath("format").text,
      size: node.xpath("sizeBytes").text,
      mime_type: node.xpath("mimeType").text,
      sequence: node.xpath("sequenceId").text
    }
  end
  accumulator.concat [bitstreams.to_json.to_s]
end
