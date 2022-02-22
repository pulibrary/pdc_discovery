# frozen_string_literal: true
describe 'catalog/index', type: :system do
  context 'when on the hompage' do
    it 'shows the footer' do
      visit '/'
      expect(page).to have_selector('#footer')
    end
  end

  context 'when performing a search' do
    it 'shows the footer' do
      visit '/?search_field=all_fields&q=abc'
      expect(page).to have_selector('#footer')
    end
  end
end
