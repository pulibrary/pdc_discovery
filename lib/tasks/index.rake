# frozen_string_literal: true

namespace :index do
  desc 'CRON JOB Re-index all research data'
  task research_data: :environment do
    older_timestamp = DateTime.now.utc - 1.second

    Rails.logger.info "Indexing: Research Data indexing started"
    DescribeIndexer.new.index
    Indexing::SolrCloudHelper.collection_alias_commit!
    Rails.logger.info "Indexing: Harvesting and indexing PDC Describe data completed"
    Indexing::SolrCloudHelper.delete_older_documents(older_timestamp)
  rescue => ex
    Rails.logger.error("Indexing: Error indexing research data. #{ex.message}")
    Honeybadger.notify("Indexing: Error indexing research data. #{ex.message}")
  end

  desc 'Remove all indexed Documents from Solr'
  task delete_solr_all: :environment do
    Rails.logger.info "Deleting all Solr documents"
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
  end

  desc 'Index fixture data'
  task fixtures: :environment do
    indexer = DescribeIndexer.new

    fixture_names = ['pdc_describe_active_embargo.json', 'pdc_describe_expired_embargo.json']
    fixture_names.each do |fixture_name|
      fixture_path = Rails.root.join("spec", "fixtures", "files", fixture_name)
      fixture_json = File.read(fixture_path)
      indexer.index_one(fixture_json)
    end
    Indexing::SolrCloudHelper.collection_writer_commit!
  end
end
