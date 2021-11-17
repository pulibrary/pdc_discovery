# frozen_string_literal: true
describe 'catalog/index', type: :system do

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
