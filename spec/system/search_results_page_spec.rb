# frozen_string_literal: true
require 'rails_helper'

describe 'Search Results Page', type: :system, js: true do
  before do
    load_describe_dataset
    page.driver.browser.manage.window.resize_to(2000, 2000)
  end

  it "renders expected fields" do
    visit '/?search_field=all_fields&q='
    click_on "Collection Tags"
    click_on "NSTX"
    expect(page).to have_link('Midplane neutral density profiles in the National Spherical Torus Experiment', href: '/catalog/doi-10-11578-1366462')
    expect(page).to have_content 'Stotler, D.; Scotti, F.; Bell, R. E.; Diallo, A.' # authors
    # expect(page).to have_content 'Atomic and molecular density data in the outer midplane of NSTX' # abstract
  end

  describe "title searches" do
    it "finds record by title" do
      # Notice that the search is successful even with a slight variation in terms (profile vs profiles)
      visit '/?search_field=title&q=profile'
      expect(page).to have_link('Midplane neutral density profiles in the National Spherical Torus Experiment', href: '/catalog/doi-10-11578-1366462')
    end
    it "does not find non-existing titles" do
      visit '/?search_field=title&q=crofile'
      expect(page).to have_content('No results found')
    end
  end

  describe "author searches" do
    it "finds record by author" do
      visit '/?search_field=author&q=podesta'
      expect(page).to have_link('Midplane neutral density profiles in the National Spherical Torus Experiment', href: '/catalog/doi-10-11578-1366462')
    end

    it "finds record by author synonym" do
      visit '/?search_field=author&q=dan'
      expect(page).to have_content("Author(s):\nTrueman, Daniel")
      expect(page).to have_link('bitKlavier Grand Sample Library—Piano Bar Mic Image', href: '/catalog/doi-10-34770-r75s-9j74')
    end
  end

  describe "bookmarks" do
    it "does not render bookmark checkboxes" do
      visit '/?search_field=author&q=podesta'
      expect(page).not_to have_css "div.toggle-bookmark"
    end
  end

  describe "facets" do
    it "shows expected facets" do
      visit '/?search_field=all_fields&q='
      domain_facet_html = '<div class="card facet-limit blacklight-domain_ssim ">'
      expect(page.html.include?(domain_facet_html)).to be true

      community_facet_html = '<div class="card facet-limit blacklight-communities_ssim ">'
      expect(page.html.include?(community_facet_html)).to be true

      type_facet_html = '<div class="card facet-limit blacklight-genre_ssim ">'
      expect(page.html.include?(type_facet_html)).to be true

      year_facet_html = '<div class="card facet-limit blacklight-year_available_itsi ">'
      expect(page.html.include?(year_facet_html)).to be true
    end

    it "shows collection facet for PPPL" do
      visit '/?f%5Bcommunities_ssim%5D%5B%5D=Princeton+Plasma+Physics+Laboratory'
      collection_facet_html = '<div class="card facet-limit blacklight-collection_tag_ssim ">'
      expect(page.html.include?(collection_facet_html)).to be true
    end

    it "shows collection facet for Music and Arts" do
      visit '/?f%5Bcommunities_ssim%5D%5B%5D=Music+and+Arts'
      collection_facet_html = '<div class="card facet-limit blacklight-collection_tag_ssim ">'
      expect(page.html.include?(collection_facet_html)).to be true
    end

    it "searches by the keyword facet even thought it is a hidden facet" do
      visit '/?f%5Bsubject_all_ssim%5D%5B%5D=Monte-Carlo+simulation'
      expect(page.html.include?("Keywords")).to be true
      expect(page.html.include?("Monte-Carlo simulation")).to be true
    end
  end

  describe "bot searches" do
    it "handles searches with invalid date ranges" do
      # Notice that the search includes year_available_itsi {"begin"=>"2020", "end"=>"'" }
      visit "/?per_page=100&range%5Byear_available_itsi%5D%5Bbegin%5D=2020&range%5Byear_available_itsi%5D%5Bend%5D=2020&range%5Byear_available_itsi%5D%5Bend%5D=%27&range_end=2025&range_field=year_available_itsi&range_start=2013"
      expect(page.html.include?("Invalid Search")).to be true
    end
  end
end
