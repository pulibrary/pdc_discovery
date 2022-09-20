# frozen_string_literal: true

describe 'Website banner', type: :system, js: true do
  let(:community_fetch_with_expanded_metadata) { file_fixture("single_item.xml").read }
  let(:indexer) do
    DspaceIndexer.new(community_fetch_with_expanded_metadata)
  end

  before do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    indexer.index
  end

  it "has the banner on the homepage" do
    visit '/'
    expect(page).to have_css '#banner'
  end

  it "has the banner on a static page" do
    visit '/about'
    expect(page).to have_css '#banner'
  end

  it "has the banner on the search results page" do
    visit '/?search_field=all_fields&q=test'
    expect(page).to have_css '#banner'
  end

  it "has the banner on a single record page" do
    visit '/catalog/78348'
    expect(page).to have_css '#banner'
  end

  it "renders html tags in the banner" do
    visit '/catalog/78348'
    expect(page).not_to have_content "<i>test</i>"
    expect(page.find("div#banner h1 i").text).to eq "test"
    expect(page).not_to have_content "<b>test</b>"
    expect(page.find("div#banner p b").text).to eq "test"
    expect(page).to have_link "message", href: "mailto:fake@princeton.edu"
  end
end
