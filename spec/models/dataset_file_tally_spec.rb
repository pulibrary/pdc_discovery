# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe DatasetFileTally do
  before(:all) do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    load_describe_dataset
  end

  let(:timestamp) { Time.parse("2025-03-25 18:01") }
  let(:dft) { described_class.new(timestamp) }

  it 'has a timestamp' do
    expect(dft.timestamp.year).to eq Time.now.year
  end

  it 'makes a filename based on the date and time' do
    expect(dft.filename).to eq "2025_03_25_18_01.csv"
  end

  it 'writes the file to a configurable directory' do
    expect(dft.filepath).to eq Rails.root.join("tmp", "dataset_file_tally", dft.filename).to_s
  end


  # it 'queries for all of the files in solr' do
  #   expect(dft.query_all_files["response"]["numFound"]).to eq 67
  # end

end