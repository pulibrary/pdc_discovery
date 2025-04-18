# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Dynamic Sitemap', type: :system, js: false do
  before do
    load_describe_small_data
  end

  context 'index' do
    it 'renders XML with a root element' do
      visit '/sitemap#index'
      expect(page).to have_xpath('//sitemapindex')
    end
    it 'renders at least 16 <sitemap> elements' do
      visit blacklight_dynamic_sitemap.sitemap_index_path
      expect(page).to have_xpath('//sitemap', count: 16)
    end
  end

  context 'show' do
    it 'renders XML with a root element' do
      visit blacklight_dynamic_sitemap.sitemap_path('1')
      expect(page).to have_xpath('//urlset')
    end
    it 'renders <url> elements' do
      visit blacklight_dynamic_sitemap.sitemap_path('c')
      expect(page).to have_xpath('//url', count: 1)
    end
  end
end
