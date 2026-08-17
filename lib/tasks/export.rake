# frozen_string_literal: true

namespace :export do
  desc "Exports a summary of the existing datasets"
  task summary: :environment do
    tally = DatasetFileTally.new
    tally.summary
    puts "Export available at #{tally.filepath_summary}"
  end

  desc "Exports the file list for each dataset"
  task details: :environment do
    tally = DatasetFileTally.new
    tally.details
    puts "Export available at #{tally.filepath_details}"
  end
end
