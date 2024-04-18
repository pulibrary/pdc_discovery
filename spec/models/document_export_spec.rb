# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
RSpec.describe DocumentExport do
  let(:files_pdc_describe) do
    [{ name: "file1.zip", full_name: "/folder1/file1.zip", size: 27, url: "https://pdc_describe" }, { name: "data.csv", size: 100 }, { name: "file2.zip", size: 200 }]
  end

  let(:files_dataspace) do
    [{ name: "file1.zip", size: 27, handle: "xyz" }, { name: "data.csv", size: 29, handle: "yzx" }, { name: "file2.zip", size: 28, handle: "zxy" }]
  end

  let(:solr_doc_pdc_describe) do
    SolrDocument.new({
                       id: "1", title_tesim: ["Hello World"], files_ss: files_pdc_describe.to_json,
                       data_source_ssi: "pdc_describe",
                       description_tsim: ["Something"],
                       abstract_tsim: ["Abstract"],
                       uri_ssim: ["https://doi.org/10.34770/bm4s-t361"],
                       embargo_date_dtsi: "2025-11-28",
                       globus_uri_ssi: "https://app.globus.org/file-manager?origin_id=something-something",
                       authors_json_ss: "[{\"value\":\"Alt, Andrew\",\"name_type\":\"Personal\",\"given_name\":\"Andrew\",\"family_name\":\"Alt\",\"identifier\":{\"value\":\"0000-0001-9475-8282\",\"scheme\":\"ORCID\",\"scheme_uri\":\"https://orcid.org\"},\"affiliations\":[{\"value\":\"Princeton Plasma Physics Laboratory\",\"identifier\":\"https://ror.org/03vn1ts68\",\"scheme\":\"ROR\",\"scheme_uri\":null}],\"sequence\":0},{\"value\":\"Ji, Hantao\",\"name_type\":\"Personal\",\"given_name\":\"Hantao\",\"family_name\":\"Ji\",\"identifier\":{\"value\":\"0000-0001-9600-9963\",\"scheme\":\"ORCID\",\"scheme_uri\":\"https://orcid.org\"},\"affiliations\":[{\"value\":\"Princeton Plasma Physics Laboratory\",\"identifier\":\"https://ror.org/03vn1ts68\",\"scheme\":\"ROR\",\"scheme_uri\":null}],\"sequence\":1},{\"value\":\"Yoo, Jongsoo\",\"name_type\":\"Personal\",\"given_name\":\"Jongsoo\",\"family_name\":\"Yoo\",\"identifier\":{\"value\":\"0000-0003-3881-1995\",\"scheme\":\"ORCID\",\"scheme_uri\":\"https://orcid.org\"},\"affiliations\":[{\"value\":\"Princeton Plasma Physics Laboratory\",\"identifier\":\"https://ror.org/03vn1ts68\",\"scheme\":\"ROR\",\"scheme_uri\":null}],\"sequence\":2},{\"value\":\"Bose, Sayak\",\"name_type\":\"Personal\",\"given_name\":\"Sayak\",\"family_name\":\"Bose\",\"identifier\":{\"value\":\"0000-0001-8093-9322\",\"scheme\":\"ORCID\",\"scheme_uri\":\"https://orcid.org\"},\"affiliations\":[{\"value\":\"Princeton Plasma Physics Laboratory\",\"identifier\":\"https://ror.org/03vn1ts68\",\"scheme\":\"ROR\",\"scheme_uri\":null}],\"sequence\":3},{\"value\":\"Goodman, Aaron\",\"name_type\":\"Personal\",\"given_name\":\"Aaron\",\"family_name\":\"Goodman\",\"identifier\":{\"value\":\"0000-0003-3639-6572\",\"scheme\":\"ORCID\",\"scheme_uri\":\"https://orcid.org\"},\"affiliations\":[{\"value\":\"Princeton Plasma Physics Laboratory\",\"identifier\":\"https://ror.org/03vn1ts68\",\"scheme\":\"ROR\",\"scheme_uri\":null}],\"sequence\":4},{\"value\":\"Yamada, Masaaki\",\"name_type\":\"Personal\",\"given_name\":\"Masaaki\",\"family_name\":\"Yamada\",\"identifier\":{\"value\":\"0000-0003-4996-1649\",\"scheme\":\"ORCID\",\"scheme_uri\":\"https://orcid.org\"},\"affiliations\":[{\"value\":\"Princeton Plasma Physics Laboratory\",\"identifier\":\"https://ror.org/03vn1ts68\",\"scheme\":\"ROR\",\"scheme_uri\":null}],\"sequence\":5}]"
                     })
  end

  let(:solr_doc_dataspace) do
    SolrDocument.new({ id: "1", title_tesim: ["Hello World"], files_ss: files_dataspace.to_json, data_source_ssi: "dataspace", description_tsim: ["Something"], abstract_tsim: ["Abstract"] })
  end

  it "returns DocumentExport object's information from pdc_describe" do
    document = described_class.new(solr_doc_pdc_describe)
    expect(document.id).to be "1"
    expect(document.title).to be "Hello World"
    expect(document.files.count).to eq 3
    expect(document.description).to eq "Something"
    expect(document.abstract).to eq "Abstract"
    expect(document.files.first.name).to eq "file1.zip"
    expect(document.files.first.full_path).to eq "/folder1/file1.zip"
    expect(document.files.first.download_url).to eq "https://pdc_describe"
    expect(document.doi_value).to eq "10.34770/bm4s-t361"
    expect(document.doi_url).to eq "https://doi.org/10.34770/bm4s-t361"
    expect(document.embargo_date).to eq Date.parse("2025-11-28")
    expect(document.total_file_size).to eq 327
    expect(document.globus_url).to eq "https://app.globus.org/file-manager?origin_id=something-something"
    expect(document.authors.count).to be 6
    expect(document.authors[0].value).to eq "Alt, Andrew"
  end

  it "returns DocumentExport object's information from dataspace" do
    document = described_class.new(solr_doc_dataspace)
    expect(document.id).to be "1"
    expect(document.title).to be "Hello World"
    expect(document.files.count).to eq 3
    expect(document.description).to eq "Something"
    expect(document.abstract).to eq "Abstract"
    expect(document.files.first.name).to eq "file1.zip"
    expect(document.files.first.download_url).to eq "https://dataspace-dev.princeton.edu/bitstream/xyz/0"
  end
end
# rubocop:enable Layout/LineLength
