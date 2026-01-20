# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe DatasetFileTally do
  before(:all) do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    load_describe_small_data
  end

  let(:dft) { described_class.new(timestamp) }
  let(:timestamp) { Time.zone.parse("2025-03-25 18:01") }
  let(:file_info_line) { "doi-10-34770-r75s-9j74,bitKlavier Grand Sample Library—Binaural Mic Image,2021,4,1108910,folder-a/file3.txt,396003,https" }

  it 'has a timestamp' do
    expect(dft.timestamp.year >= 2025).to be true
  end

  it 'makes a filename based on the date and time' do
    expect(dft.filename_summary).to eq "2025_03_25_18_01_summary.csv"
    expect(dft.filename_details).to eq "2025_03_25_18_01_details.csv"
  end

  it 'writes the file to a configurable directory' do
    expect(dft.filepath_summary).to eq Rails.root.join("tmp", "dataset_file_tally", dft.filepath_summary).to_s
  end

  context "#summary" do
    let(:timestamp) { Time.zone.parse("2025-03-25 18:02") }

    it 'produces an export with the sumamry data only' do
      dft.summary
      lines = File.readlines(dft.filepath_summary)
      expect(lines.count).to be 3
      expect(lines[0]).to eq "id,title,issue_date,file_count,total_file_size\n"
      expect(lines[1]).to eq "doi-10-34770-00yp-2w12,Sowing the Seeds for More Usable Web Archives: A Usability Study of Archive-It,2023,0,0\n"
      expect(lines[2]).to eq "doi-10-34770-r75s-9j74,bitKlavier Grand Sample Library—Binaural Mic Image,2021,4,1108910\n"
    end
  end

  context "#details" do
    let(:timestamp) { Time.zone.parse("2025-03-25 18:03") }

    it 'produces an export with the file list included' do
      dft.details
      lines = File.readlines(dft.filepath_details)
      expect(lines.count).to eq 5
      expect(lines[0]).to eq "id,title,issue_date,file_count,total_file_size,file_name,file_size,url\n"
      expect(lines.find { |line| line.start_with?(file_info_line) }).to_not be nil
    end
  end
end
