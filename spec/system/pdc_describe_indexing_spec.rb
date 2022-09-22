# frozen_string_literal: true

describe 'PDC Describe research data indexing', type: :system do
  subject(:result) do
    indexer.map_record(record)
  end
  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Rails.root.join('lib', 'traject', 'pdc_describe_indexing_config.rb'))
    end
  end
  let(:pdc_describe_resource_xml) do
    File.join(fixture_path, 'pdc_describe', 'shakespeare.xml')
  end
  let(:nokogiri_reader) do
    Traject::NokogiriReader.new(File.read(pdc_describe_resource_xml), indexer.settings)
  end
  let(:records) do
    nokogiri_reader.to_a
  end
  let(:record) do
    records.first
  end

  xit 'id' do
    expect(result['id'].first).to eq '1301'
  end

  xit 'title' do
    expect(result['title_tesim'].first).to eq 'Seeing the Lyman-Alpha Forest for the Trees: Constraints on the Thermal State of the IGM from SDSS-III/BOSS'
  end

  xit 'referenced_by' do
    expect(result['referenced_by_ssim'].first).to eq 'https://arxiv.org/abs/1903.06605'
  end

  xit 'files' do
    # The fixture has three files but we expect two of them to be ignored
    files = JSON.parse(result['files_ss'].first)
    expect(files.count).to eq 1
    expect(files.first["name"]).to eq 'Lee_princeton_0181D_10086.pdf'
  end
end
