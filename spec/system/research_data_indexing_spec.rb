# frozen_string_literal: true

describe 'DataSpace research data indexing', type: :system do
  subject(:result) do
    indexer.map_record(record)
  end
  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Rails.root.join('lib', 'traject', 'dataspace_research_data_config.rb'))
    end
  end
  let(:dspace_xml) do
    File.join(fixture_path, 'astrophysical_sciences.xml')
  end
  let(:nokogiri_reader) do
    Traject::NokogiriReader.new(File.read(dspace_xml), indexer.settings)
  end
  let(:records) do
    nokogiri_reader.to_a
  end
  let(:record) do
    records.first
  end

  it 'id' do
    expect(result['id'].first).to eq '1301'
  end

  it 'title' do
    expect(result['title_ssim'].first).to eq 'Seeing the Lyman-Alpha Forest for the Trees: Constraints on the Thermal State of the IGM from SDSS-III/BOSS'
  end

  it 'referenced_by' do
    expect(result['referenced_by_ssim'].first).to eq 'https://arxiv.org/abs/1903.06605'
  end

  it 'extent' do
    expect(result['extent_ssim'].first).to eq '45 minutes'
  end

  it 'files' do
    files = JSON.parse(result['files_ss'].first)
    expect(files.first["name"]).to eq 'Lee_princeton_0181D_10086.pdf'
  end
end
