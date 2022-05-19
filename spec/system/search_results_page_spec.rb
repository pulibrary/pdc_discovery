# frozen_string_literal: true

describe 'Search Results Page', type: :system, js: true do
  before do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
    data = file_fixture('search_results_items.xml').read
    indexer = Indexer.new(data)
    indexer.index
  end

  it "renders expected fields" do
    visit '/?search_field=all_fields&q='

    expect(page).to have_link('Midplane neutral density profiles in the National Spherical Torus Experiment', href: '/catalog/78348')
    expect(page).to have_content 'Stotler, D.; F. Scotti; R.E. Bell; A. Diallo' # authors
    expect(page).to have_content 'Atomic and molecular density data in the outer midplane of NSTX' # abstract
  end

  describe "title searches" do
    it "finds record by title" do
      # Notice that the search is successful even with a slight variation in terms (profile vs profiles)
      visit '/?search_field=title&q=profile'
      expect(page).to have_link('Midplane neutral density profiles in the National Spherical Torus Experiment', href: '/catalog/78348')
    end
    it "does not find non-existing titles" do
      visit '/?search_field=title&q=crofile'
      expect(page).to have_content('No results found')
    end
  end

  describe "author searches" do
    it "finds record by author" do
      visit '/?search_field=author&q=podesta'
      expect(page).to have_link('Midplane neutral density profiles in the National Spherical Torus Experiment', href: '/catalog/78348')
    end

    it "finds record by author synonym" do
      visit '/?search_field=author&q=dan'
      expect(page).to have_content("Author(s):\nTrueman, Daniel")
      expect(page).to have_link('bitKlavier Grand Sample Library—Piano Bar Mic Image', href: '/catalog/123476')
    end
  end

  describe "bookmarks" do
    it "does not render bookmark checkboxes" do
      visit '/?search_field=author&q=podesta'
      expect(page).not_to have_css "div.toggle-bookmark"
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe "facets" do
    it "shows expected facets" do
      visit '/?search_field=all_fields&q='
      domain_facet_html = '<div class="card facet-limit blacklight-domain_ssi ">'
      expect(page.html.include?(domain_facet_html)).to be true

      community_facet_html = '<div class="card facet-limit blacklight-community_root_name_ssi ">'
      expect(page.html.include?(community_facet_html)).to be true

      type_facet_html = '<div class="card facet-limit blacklight-genre_ssim ">'
      expect(page.html.include?(type_facet_html)).to be true

      year_facet_html = '<div class="card facet-limit blacklight-year_available_itsi ">'
      expect(page.html.include?(year_facet_html)).to be true

      # Collection facet is not rendered by defailt
      collection_facet_html = '<div class="card facet-limit blacklight-collection_name_ssi ">'
      expect(page.html.include?(collection_facet_html)).to be false
    end
    # rubocop:enable RSpec/ExampleLength

    it "shows collection facet for PPPL" do
      visit '/?f%5Bcommunity_root_name_ssi%5D%5B%5D=Princeton+Plasma+Physics+Laboratory'
      collection_facet_html = '<div class="card facet-limit blacklight-collection_name_ssi ">'
      expect(page.html.include?(collection_facet_html)).to be true
    end

    it "shows collection facet for Music and Arts" do
      visit '/?f%5Bcommunity_root_name_ssi%5D%5B%5D=Music+and+Arts'
      collection_facet_html = '<div class="card facet-limit blacklight-collection_name_ssi ">'
      expect(page.html.include?(collection_facet_html)).to be true
    end

    it "searches by the keyword facet even thought it is a hidden facet" do
      visit '/?f%5Bsubject_all_ssim%5D%5B%5D=Monte-Carlo+simulation'
      expect(page.html.include?("Keywords")).to be true
      expect(page.html.include?("Monte-Carlo simulation")).to be true
    end
  end
end
