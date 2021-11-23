# frozen_string_literal: true

describe 'DataSpace research data all fields indexing', type: :system do
  subject(:result) do
    indexer.map_record(record)
  end
  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Rails.root.join('lib', 'traject', 'dataspace_research_data_config.rb'))
    end
  end
  let(:dspace_xml) do
    File.join(fixture_path, 'single_item_all_fields.xml')
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
    expect(result['id'].first).to eq '96151'
  end

  it 'title' do
    expect(result['title_ssim'].first).to eq 'Sowing the Seeds for More Usable Web Archives: A Usability Study of Archive-It'
  end

  it 'extent' do
    expect(result['extent_ssim'].first).to eq '45 minutes'
  end

end
