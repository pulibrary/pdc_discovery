# frozen_string_literal: true

describe 'Item page with Globus download integration', type: :system, js: true do
  let(:globus_fixtures) { File.read(File.join(fixture_path, 'globus_items.xml')) }
  let(:indexer) do
    Indexer.new(globus_fixtures)
  end

  before do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    indexer.index
  end

  it "displays the Globus download button when the integration is present" do
    visit '/catalog/88163'
    expect(page).to have_content "Download from Globus"
  end

  it "does not display the Globus download button when the integration is not present" do
    visit '/catalog/6517'
    expect(page).not_to have_content "Download from Globus"
  end
end
