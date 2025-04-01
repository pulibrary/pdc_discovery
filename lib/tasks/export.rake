# frozen_string_literal: true

namespace :export do
  desc "Exports to the console the inventory of dataset and their files"
  task datasets: :environment do
    tally = DatasetFileTally.new
    tally.export
  end
end
