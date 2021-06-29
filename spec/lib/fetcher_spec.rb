# frozen_string_literal: true

RSpec.describe Fetcher do
  let(:server) { 'https://dataspace-dev.princeton.edu/rest/' }
  let(:community) { '85' } # Astrophysical Sciences
  let(:fetcher) { described_class.new(server: server, community: community) }

  it 'has a server and a community to harvest from' do
    expect(fetcher).to be_instance_of(Fetcher)
    expect(fetcher.server).to eq server
    expect(fetcher.community).to eq community
  end
end
