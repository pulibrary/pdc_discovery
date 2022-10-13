# frozen_string_literal: true

describe 'PDC Describe research data indexing -- Bitklavier', type: :system do
  subject(:result) { indexer.map_record(record) }
  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Rails.root.join('lib', 'traject', 'pdc_describe_indexing_config.rb'))
    end
  end
  let(:pdc_describe_resource_xml) { File.join(fixture_path, 'pdc_describe', 'bitklavier_binaural.xml') }
  let(:nokogiri_reader) { Traject::NokogiriReader.new(File.read(pdc_describe_resource_xml), indexer.settings) }
  let(:records) { nokogiri_reader.to_a }
  let(:record) { records.first }

  ##
  # The id is based on the DOI
  # A doi of 10.34770/pe9w-x904 will become doi-10-34770-pe9w-x904
  it 'id' do
    expect(result['id'].first).to eq "doi-10-34770-r75s-9j74"
  end

  # ==================
  # author fields
  it 'gets all the authors' do
    authors = ["Trueman, Daniel", "Wang, Matthew", "Villalta, Andrés", "Chou, Katie", "Ayres, Christien"]
    expect(result['author_tesim']).to eq authors
  end

  # ==================
  # title fields
  it 'title' do
    expect(result['title_tesim'].first).to eq 'bitKlavier Grand Sample Library—Binaural Mic Image'
  end

  # ==================
  # description
  it 'description' do
    expect(result['description_tsim'].first).to match(/The bitKlavier Grand consists of sample collections/)
  end

  # ==================
  # genre / type
  it 'genre / type / resource type' do
    expect(result['genre_ssim']).to contain_exactly('Dataset')
  end

  # ==================
  # issue date - date in search results
  it 'has an issue date' do
    expect(result['issue_date_ssim']).to contain_exactly('2021')
  end

  # ==================
  # rights / license
  it 'has a license with a name and a uri' do
    expect(result['rights_name_ssi']).to contain_exactly('Creative Commons Attribution 4.0 International')
    expect(result['rights_uri_ssi']).to contain_exactly('https://creativecommons.org/licenses/by/4.0/')
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
