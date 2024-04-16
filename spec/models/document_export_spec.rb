# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentExport do
  it "returns DocumentExport object's information from pdc_describe" do
    files = [{ name: "file1.zip", full_name: "/folder1/file1.zip", size: 27, url: "https://pdc_describe" }, { name: "data.csv" }, { name: "file2.zip" }]
    solr_doc = SolrDocument.new({ id: "1", title_tesim: ["Hello World"], files_ss: files.to_json, data_source_ssi: "pdc_describe", description_tsim: ["Something"], abstract_tsim: ["Abstract"] })
    document = described_class.new(solr_doc)
    expect(document.id).to be "1"
    expect(document.title).to be "Hello World"
    expect(document.files.count).to eq 3
    expect(document.description).to eq "Something"
    expect(document.abstract).to eq "Abstract"
    expect(document.files.first.name).to eq "file1.zip"
    expect(document.files.first.full_path).to eq "/folder1/file1.zip"
    expect(document.files.first.download_url).to eq "https://pdc_describe"
  end

  it "returns DocumentExport object's information from dataspace" do
    files = [{ name: "file1.zip", size: 27, handle: "xyz" }, { name: "data.csv", size: 29, handle: "yzx" }, { name: "file2.zip", size: 28, handle: "zxy" }]
    solr_doc = SolrDocument.new({ id: "1", title_tesim: ["Hello World"], files_ss: files.to_json, data_source_ssi: "dataspace", description_tsim: ["Something"], abstract_tsim: ["Abstract"] })
    document = described_class.new(solr_doc)
    expect(document.id).to be "1"
    expect(document.title).to be "Hello World"
    expect(document.files.count).to eq 3
    expect(document.description).to eq "Something"
    expect(document.abstract).to eq "Abstract"
    expect(document.files.first.name).to eq "file1.zip"
    expect(document.files.first.download_url).to eq "https://dataspace-dev.princeton.edu/bitstream/xyz/0"
  end
end
