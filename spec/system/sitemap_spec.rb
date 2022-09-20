# frozen_string_literal: true

RSpec.describe 'Dynamic Sitemap', type: :system, js: false do
  let(:globus_fixtures) { File.read(File.join(fixture_path, 'globus_items.xml')) }
  let(:indexer) do
    DspaceIndexer.new(globus_fixtures)
  end

  before do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    indexer.index
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
      visit blacklight_dynamic_sitemap.sitemap_path('1')
      expect(page).to have_xpath('//url', count: 1)
    end
  end
end
