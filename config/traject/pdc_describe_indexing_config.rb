# frozen_string_literal: true

require 'logger'
require 'traject'
require 'traject/nokogiri_reader'
require 'blacklight'
require 'indexing'

##
# If you need to debug PDC Describe indexing, change the log level to Logger::DEBUG
settings do
  provide 'solr.url', Indexing::SolrCloudHelper.collection_writer_url
  provide 'reader_class_name', 'Traject::NokogiriReader'
  provide 'solr_writer.commit_on_close', 'true'

  # There are some parameters in Traject that allows us to configure values related
  # to the Solr connection, in particular `batch_size` and the `thread_pool`. However,
  # given that we are calling traject for each individual record (rather than for a
  # batch of records) they might not apply to our scenario.
  #
  # The documentation is here in case we want to try them out:
  # https://www.rubydoc.info/gems/traject/Traject/SolrJsonWriter

  provide 'repository', ENV['REPOSITORY_ID']
  provide 'logger', Logger.new($stderr, level: Logger::WARN)
end

# Converting the XML to JSON is a bit expensive therefore we make that conversion
# only once per record and save it to the context so that we can re-use it.
each_record do |record, context|
  xml = record.xpath("/hash").first.to_xml
  context.clipboard[:record_json] = Hash.from_xml(xml)["hash"].to_json
end

# ==================
# Main fields

to_field 'id' do |record, accumulator, _c|
  raw_doi = record.xpath("/hash/resource/doi/text()").to_s
  munged_doi = "doi-" + raw_doi.tr('/', '-').tr('.', '-')
  accumulator.concat [munged_doi]
end

to_field 'pdc_describe_json_ss' do |_record, accumulator, context|
  accumulator.concat [context.clipboard[:record_json]]
end

# Track the source of this record
to_field 'data_source_ssi' do |_record, accumulator, _c|
  accumulator.concat ["pdc_describe"]
end

# Was this record migrated?
to_field 'migrated_bsi', extract_xpath("/hash/resource/migrated")

# to_field 'abstract_tsim', extract_xpath("/item/metadata/key[text()='dcterms.abstract']/../value")
# to_field 'creator_tesim', extract_xpath("/item/metadata/key[text()='dcterms.creator']/../value")
to_field 'contributor_tsim' do |record, accumulator, _c|
  contributor_names = record.xpath("/hash/resource/contributors/contributor/value").map(&:text)
  accumulator.concat contributor_names
end
to_field 'description_tsim', extract_xpath("/hash/resource/description")
# to_field 'handle_ssim', extract_xpath('/item/handle')
to_field 'uri_ssim' do |record, accumulator, _c|
  doi = Indexing::ImportHelper.doi_uri(record.xpath("/hash/resource/doi").text)
  ark = Indexing::ImportHelper.ark_uri(record.xpath("/hash/resource/ark").text)
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
# This replaces the single-value "collection name" from DataSpace.
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
  accumulator.concat [author_names.first]
end

# all values as strings for faceting
# TODO: Should we include contributors here since the value is for faceting?
to_field 'author_ssim' do |record, accumulator, _c|
  author_names = record.xpath("/hash/resource/creators/creator/value").map(&:text)
  accumulator.concat author_names
end

# Extract the author data from the pdc_describe_json and save it on its own field as JSON
to_field 'authors_json_ss' do |_record, accumulator, context|
  pdc_json = context.clipboard[:record_json]
  authors = JSON.parse(pdc_json).dig("resource", "creators") || []
  accumulator.concat [authors.to_json]
end

to_field 'authors_orcid_ssim' do |_record, accumulator, context|
  pdc_json = context.clipboard[:record_json]
  authors_json = JSON.parse(pdc_json).dig("resource", "creators") || []
  orcids = authors_json.map { |author| Author.new(author).orcid }
  accumulator.concat orcids.compact.uniq
end

to_field 'authors_affiliation_ssim' do |_record, accumulator, context|
  pdc_json = context.clipboard[:record_json]
  authors_json = JSON.parse(pdc_json).dig("resource", "creators") || []
  affiliations = authors_json.map { |author| Author.new(author).affiliation_name }
  accumulator.concat affiliations.compact.uniq
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

to_field 'issue_date_ssim', extract_xpath("/hash/resource/publication-year")

to_field 'year_available_itsi', extract_xpath("/hash/resource/publication-year")

to_field 'pdc_created_at_dtsi', extract_xpath('/hash/created-at')

to_field "issue_date_strict_ssi" do |record, accumulator, _context|
  migrated = record.xpath("/hash/resource/migrated/text()").to_s
  date = if migrated == "true"
           pub_year = record.xpath("/hash/resource/publication-year/text()").to_s
           "#{pub_year}-01-01"
         else
           date_value = record.xpath("/hash/created-at/text()").to_s
           begin
             DateTime.parse(date_value).strftime('%Y-%m-%d')
           rescue
             nil
           end
         end
  if date
    accumulator.concat [date]
  end
end

to_field 'pdc_updated_at_dtsi', extract_xpath('/hash/updated-at')

# ==================
# publisher fields
to_field 'publisher_ssim', extract_xpath("/hash/resource/publisher")
# to_field 'publisher_place_ssim', extract_xpath("/item/metadata/key[text()='dc.publisher.place']/../value")
# to_field 'publisher_corporate_ssim', extract_xpath("/item/metadata/key[text()='dc.publisher.corporate']/../value")

# # ==================
# # rights fields
to_field 'rights_name_ssi', extract_xpath("/hash/resource/rights/name")
to_field 'rights_uri_ssi', extract_xpath("/hash/resource/rights/uri")

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

# ==================
# Embargo Date
# Store and index the embargo date from the PDC Describe Work as a single value
to_field 'embargo_date_dtsi' do |record, accumulator, _context|
  embargo_value = record.xpath("/hash/embargo-date/text()").to_s
  valid_date = begin
                 DateTime.parse(embargo_value)
               rescue
                 nil
               end
  if valid_date
    accumulator.concat [embargo_value]
  end
end

# Calculate the URI to the globus folder for this dataset
to_field 'globus_uri_ssi' do |record, accumulator, _context|
  filename = record.xpath("/hash/files/file/filename/text()").first&.text
  if filename
    globus_uri = Indexing::ImportHelper.globus_folder_uri_from_file(filename)
    accumulator.concat [globus_uri]
  end
end

# Version number
to_field 'version_number_ssi' do |record, accumulator, _context|
  version_number = record.xpath("/hash/resource/version-number/text()").first&.text
  accumulator.concat [version_number]
end

# Indexes the entire text in a catch-all field.
to_field 'all_text_teimv' do |record, accumulator, _context|
  accumulator.concat [record.text]
end
