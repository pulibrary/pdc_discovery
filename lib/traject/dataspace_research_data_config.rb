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
to_field 'author_tsim', extract_xpath("/item/metadata/key[text()='dc.contributor.author']/../value")
to_field 'contributor_tsim', extract_xpath("/item/metadata/key[text()='dc.contributor']/../value")
to_field 'description_tsim', extract_xpath("/item/metadata/key[text()='dc.description']/../value")
to_field 'handle_ssm', extract_xpath('/item/handle')
to_field 'id', extract_xpath('/item/id')
to_field 'title_ssm', extract_xpath('/item/name')
to_field 'title_tsim', extract_xpath('/item/name')
to_field 'uri_tsim', extract_xpath("/item/metadata/key[text()='dc.identifier.uri']/../value")

# ==================
# contributor fields

to_field 'advisor_tsim', extract_xpath("/item/metadata/key[text()='dc.contributor.advisor']/../value")
to_field 'editor_tsim', extract_xpath("/item/metadata/key[text()='dc.contributor.editor']/../value")
to_field 'illustrator_tsim', extract_xpath("/item/metadata/key[text()='dc.contributor.illustrator']/../value")
to_field 'other_contributor_tsim', extract_xpath("/item/metadata/key[text()='dc.contributor.other']/../value")
to_field 'creator_tsim', extract_xpath("/item/metadata/key[text()='dc.creator']/../value")

# ==================
# coverage fields

to_field 'spatial_coverage_tsim', extract_xpath("/item/metadata/key[text()='dc.coverage.spatial']/../value")
to_field 'temporal_coverage_tsim', extract_xpath("/item/metadata/key[text()='dc.coverage.temporal']/../value")

# ==================
# date fields

to_field "copyright_date_ssm" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.copyright']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_ssm" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_accessioned_ssm" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.accessioned']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_available_ssm" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.available']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_created_ssm" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.created']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "date_submitted_ssm" do |record, accumulator, _context|
  dates = record.xpath("/item/metadata/key[text()='dc.date.submitted']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(dates)
end

to_field "issue_date_ssm" do |record, accumulator, _context|
  issue_dates = record.xpath("/item/metadata/key[text()='dc.date.issued']/../value").map(&:text)
  accumulator.concat DateNormalizer.format_array_for_display(issue_dates)
end
