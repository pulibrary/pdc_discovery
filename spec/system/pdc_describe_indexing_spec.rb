# frozen_string_literal: true

describe 'PDC Describe research data indexing', type: :system do
  subject(:result) { indexer.map_record(record) }
  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Rails.root.join('lib', 'traject', 'pdc_describe_indexing_config.rb'))
    end
  end
  let(:pdc_describe_resource_xml) { File.join(fixture_path, 'pdc_describe', 'shakespeare.xml') }
  let(:nokogiri_reader) { Traject::NokogiriReader.new(File.read(pdc_describe_resource_xml), indexer.settings) }
  let(:records) { nokogiri_reader.to_a }
  let(:record) { records.first }

  ##
  # The id is based on the DOI
  # A doi of 10.34770/pe9w-x904 will become doi-10-34770-pe9w-x904
  it 'id' do
    expect(result['id'].first).to eq 'doi-10-34770-pe9w-x904'
  end

  # ==================
  # author fields
  it 'gets all the authors' do
    authors = [
      'Kotin, Joshua',
      'Koeser, Rebecca Sutton',
      'Adair, Carl'
    ]
    expect(result['author_tesim']).to eq authors
  end

  # ==================
  # title fields
  it 'title' do
    expect(result['title_tesim'].first).to eq 'Shakespeare and Company Project Dataset: Lending Library Members, Books, Events'
  end

  xit 'referenced_by' do
    expect(result['referenced_by_ssim'].first).to eq 'https://arxiv.org/abs/1903.06605'
  end

  # ==================
  # publisher fields
  it 'indexes publisher fields' do
    expect(result['publisher_ssim'].first).to eq 'Princeton University'
  end

  ##
  # TODO: Index filenames for PDC Describe objects
  xit 'files' do
    # The fixture has three files but we expect two of them to be ignored
    files = JSON.parse(result['files_ss'].first)
    expect(files.count).to eq 1
    expect(files.first["name"]).to eq 'Lee_princeton_0181D_10086.pdf'
  end
end
