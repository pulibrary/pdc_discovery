# frozen_string_literal: true

describe 'Application landing page', type: :system do
  let(:recently_added) { file_fixture("recent.json") }
  before do
    stub_request(:get, "http://www.example.com//catalog.json").to_return(
      status: 200,
      body: recently_added,
      headers: {
        'Content-Type' => 'application/json;charset=UTF-8',
        'Accept' => 'application/json',
        'User-Agent' => 'Faraday v1.0.1'
      }
    )
  end

  # rubocop:disable RSpec/ExampleLength
  it "renders Bootstrap icons for Recently added feed" do
    visit '/'
    expect(page).to have_css 'li#recently-added-84912 i.bi-stack'
    expect(page).to have_css 'li#recently-added-90553 i.bi-film'
    expect(page).to have_css 'li#recently-added-85707 i.bi-code-slash'
    expect(page).to have_css 'li#recently-added-88912 i.bi-image'
    expect(page).to have_css 'li#recently-added-88970 i.bi-card-text'
    expect(page).to have_css 'li#recently-added-80489 i.bi-collection-fill'
    expect(page).to have_css 'li#recently-added-87751 i.bi-journal-text'
    expect(page).to have_css 'li#recently-added-78348 i.bi-pc-display-horizontal'
    expect(page).to have_css 'li#recently-added-84484 i.bi-file-earmark-fill'
  end
  # rubocop:enable RSpec/ExampleLength

  it "has a footer with latest deploy information" do
    visit '/'
    expect(page).to have_content "last updated"
  end
end
