# frozen_string_literal: true
describe 'catalog/index', type: :system do
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
  context 'when on the hompage' do
    it 'does not show the navbar search' do
      visit '/'
      expect(page).not_to have_selector('div.navbar-search')
    end
  end

  context 'when performing a search' do
    it 'shows the navbar search' do
      visit '/?search_field=all_fields&q=abc'
      expect(page).to have_selector('div.navbar-search')
    end
  end

  context 'when performing an empty search' do
    it 'shows the navbar search' do
      visit '/?search_field=all_fields&q='
      expect(page).to have_selector('div.navbar-search')
    end
  end
end
