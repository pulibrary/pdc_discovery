# frozen_string_literal: true

RSpec.describe ResearchDataHarvester do
  let(:rdh) { described_class.new }

  it "has a list of collections to index" do
    expect(rdh.collections_to_index.count).to eq 31
  end
end
