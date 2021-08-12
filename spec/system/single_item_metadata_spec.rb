# frozen_string_literal: true

describe 'Single item page', type: :system, js: true do
  let(:community_fetch_with_expanded_metadata) { File.read(File.join(fixture_path, 'single_item.xml')) }
  let(:indexer) do
    Indexer.new(community_fetch_with_expanded_metadata)
  end

  before do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    indexer.index
  end

  it "has expected metadata" do
    visit '/catalog/78348'
    expect(page).to have_content "Midplane neutral density profiles in the National Spherical Torus Experiment"
    expect(page).to have_content "88435/dsp01zg64tp300"
  end
end
