# frozen_string_literal: true
require "csv"

# A tally of all of the files in the system at a given time.
# This should allow us to generate a report on current storage,
# as well as track growth over time.
class DatasetFileTally
  DEFAULT_FILE_PATH = Rails.root.join("tmp", "dataset_file_tally")

  attr_reader :timestamp

  def initialize(timestamp = Time.zone.now)
    @timestamp = timestamp
    @batch_size = 10
  end

  def filename_summary
    @filename_summary ||= "#{@timestamp.strftime('%Y_%m_%d_%H_%M')}_summary.csv"
  end

  def filename_details
    @filename_details ||= "#{@timestamp.strftime('%Y_%m_%d_%H_%M')}_details.csv"
  end

  def filepath_summary
    directory = ENV.fetch('DATASET_FILE_TALLY_DIR', DEFAULT_FILE_PATH)
    FileUtils.mkdir_p directory
    Pathname.new(directory).join(filename_summary).to_s
  end

  def filepath_details
    directory = ENV.fetch('DATASET_FILE_TALLY_DIR', DEFAULT_FILE_PATH)
    FileUtils.mkdir_p directory
    Pathname.new(directory).join(filename_details).to_s
  end

  # Exports the dataset top level information
  def summary
    init_solr_batch
    CSV.open(filepath_summary, "w") do |csv|
      csv << ["id", "title", "issue_date", "file_count", "total_file_size"]
      loop do
        datasets = fetch_solr_batch
        break if datasets.count == 0

        datasets.each do |dataset|
          csv << [dataset.id, dataset.title, dataset.issued_date, dataset.files.count, dataset.total_file_size]
        end
      end
    end
  end

  # Exports the dataset top level information and the file list for each dataset
  def details
    init_solr_batch
    CSV.open(filepath_details, "w") do |csv|
      csv << ["id", "title", "issue_date", "file_count", "total_file_size", "file_name", "file_size", "url"]
      loop do
        datasets = fetch_solr_batch
        break if datasets.count == 0

        datasets.each do |dataset|
          dataset_tokens = [dataset.id, dataset.title, dataset.issued_date, dataset.files.count, dataset.total_file_size]
          dataset.files.each do |file|
            file_tokens = [file.full_path, file.size, file.download_url]
            tokens = dataset_tokens + file_tokens
            csv << tokens
          end
        end
      end
    end
  end

  private

  def fetch_solr_batch
    @batch += 1
    start = @batch * @batch_size
    solr_params = { q: '*:*', fl: '*', start: start, rows: @batch_size, order: 'id asc' }
    response = Blacklight.default_index.connection.get 'select', params: solr_params
    response["response"]["docs"].map { |doc| SolrDocument.new(doc) }
  end

  def init_solr_batch
    @batch = -1
  end
end
