# frozen_string_literal: true

namespace :migration do
  desc 'Produce full DataSpace migration spreadsheet'
  task produce_full_spreadsheet: :environment do
    tracking_csv = "/tmp/full_dataspace_migration_spreadsheet_#{Time.zone.now.strftime('%Y_%m_%d_%H_%M')}.csv"
    collections_csv = Rails.root.join("config", "collections.csv")
    DspaceResearchDataHarvester.new.produce_full_migration_spreadsheet(tracking_csv, collections_csv)
  end

  # Given an in-progress migration spreadsheet, harvest data from DataSpace and provide a list of all
  # items that do not appear on the in-progress migration spreadsheet.
  # 1. Download the spreadsheet as a CSV from google docs
  # 2. Name it something without spaces or special characters
  # 3. Point to it when you invoke this task
  # 4. Note that one of the header columns must be 'handle'
  desc 'Produce delta DataSpace migration spreadsheet'
  task :produce_delta_spreadsheet, [:in_progress_csv] => :environment do |_, args|
    if args[:in_progress_csv].blank?
      puts "Usage: bundle exec rake migration:produce_delta_spreadsheet\\[/full/path/to/in_progress.csv]"
      exit 1
    end
    tracking_csv = "/tmp/delta_dataspace_migration_spreadsheet_#{Time.zone.now.strftime('%Y_%m_%d_%H_%M')}.csv"
    collections_csv = Rails.root.join("config", "collections.csv")
    DspaceResearchDataHarvester.new.produce_full_migration_spreadsheet(tracking_csv, collections_csv)
  end
end
