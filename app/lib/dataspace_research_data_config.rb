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
  provide 'logger', Logger.new($stderr)
  provide "nokogiri.each_record_xpath", "//items/item"
end

# ==================
# Top level document
# ==================

to_field 'id', extract_xpath('/item/id')
to_field 'title_ssm', extract_xpath('/item/name')
