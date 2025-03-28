# frozen_string_literal: true

# A tally of all of the files in the system at a given time. 
# This should allow us to generate a report on current storage, 
# as well as track growth over time. 
class DatasetFileTally

  DEFAULT_FILE_PATH = Rails.root.join("tmp", "dataset_file_tally")

  attr_reader :timestamp, :filename, :filepath

  # The response from the current query of solr
  attr_reader :response

  def initialize(timestamp = Time.zone.now)
    @timestamp = timestamp
  end

  # Write a file named with the current timestamp
  def filename
    @filename ||= "#{@timestamp.strftime('%Y_%m_%d_%H_%M')}.csv"
  end

  # Write a file named with the current timestamp
  def filepath
    directory = ENV.fetch('DATASET_FILE_TALLY_DIR', DEFAULT_FILE_PATH)
    Pathname.new(directory).join(filename).to_s
  end

  # Get all of the documents from solr so we can go through and tally them
  def query_all_files
    @response ||= Blacklight.default_index.connection.get 'select', params: { q: '*:*', fl: 'id,pdc_describe_json_ss' }
  end

end