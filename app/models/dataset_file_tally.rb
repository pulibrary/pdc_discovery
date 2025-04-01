# frozen_string_literal: true

# A tally of all of the files in the system at a given time.
# This should allow us to generate a report on current storage,
# as well as track growth over time.
class DatasetFileTally

  DEFAULT_FILE_PATH = Rails.root.join("tmp", "dataset_file_tally")

  attr_reader :timestamp, :filename, :filepath

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

  def export
    puts "id, title, file_name, file_size, url"
    solr_docs.each do |solr_doc|
      dataset_tokens = []
      dataset_tokens << solr_doc.id
      dataset_tokens << solr_doc.title
      solr_doc.files.each do |file|
        file_tokens = []
        file_tokens << file.full_path
        file_tokens << file.size
        file_tokens << file.download_url
        tokens = dataset_tokens + file_tokens
        puts tokens.join(", ")
      end
    end
  end

  private
    def solr_docs
      @solr_docs ||= begin
        # TODO: implement pagination
        response = Blacklight.default_index.connection.get 'select', params: { q: '*:*', fl: '*' }
        response["response"]["docs"].map { |doc| SolrDocument.new(doc) }
      end
    end
end