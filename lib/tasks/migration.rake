# frozen_string_literal: true

namespace :migration do
  desc 'Produce full DataSpace migration spreadsheet'
  task produce_full_spreadsheet: :environment do
    tracking_csv = "/tmp/full_dataspace_migration_spreadsheet_#{Time.zone.now.strftime('%Y_%m_%d_%H_%M')}.csv"
    collections_csv = Rails.root.join("config", "collections.csv")
    DspaceResearchDataHarvester.new.produce_full_migration_spreadsheet(tracking_csv, collections_csv)
  end
end
