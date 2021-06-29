# frozen_string_literal: true

RSpec.describe Fetcher do
  let(:server) { 'https://dataspace-dev.princeton.edu/rest/' }
  let(:collection_id) { '85' } # Astrophysical Sciences
  let(:fetcher) { described_class.new(server: server) }

  it 'has a server to harvest from' do
    expect(fetcher).to be_instance_of(described_class)
    expect(fetcher.server).to eq server
  end

  context 'fetching data' do
    let(:oai_feed) { File.read(File.join(fixture_path, 'astrophysical_sciences.json')) }

    before do
      stub_request(:get, "#{server}/collections/#{collection_id}/items?expand=metadata&limit=100&offset=0")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Faraday v1.4.3'
          }
        )
        .to_return(status: 200, body: oai_feed, headers: {})
    end

    it 'fetches metadata for a given community' do
      datasets = fetcher.fetch_collection(collection_id)
      expect(datasets.size).to eq 39
    end
  end
end
