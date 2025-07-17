# frozen_string_literal: true
require 'rails_helper'

describe 'PDC Describe Bitklavier Single item page', type: :system, js: true do
  let(:rss_feed) { file_fixture("works.rss").read }
  let(:resource1) { file_fixture("sowing_the_seeds.json").read }
  let(:bitklavier_binaural_json) { file_fixture("bitklavier_binaural.json").read }
  let(:rss_url_string) { "https://pdc-describe-prod.princeton.edu/describe/works.rss" }
  let(:indexer) { DescribeIndexer.new(rss_url: rss_url_string) }

  before do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works.rss")
      .to_return(status: 200, body: rss_feed, headers: {})
    stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works/6.json")
      .to_return(status: 200, body: resource1, headers: {})
    stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works/20.json")
      .to_return(status: 200, body: bitklavier_binaural_json, headers: {})
    indexer.index
  end

  it "has expected header fields" do
    visit '/catalog/doi-10-34770-r75s-9j74'
    expect(page).to have_css '.document-title-heading'
    expect(page).to have_css '.authors-heading'
    expect(page).to have_css 'div.authors-heading > span.author-name'
    expect(page).to have_css '.issue-date-heading'
  end

  # rubocop:disable Layout/LineLength
  it "has expected metadata" do
    visit '/catalog/doi-10-34770-r75s-9j74'
    expect(page).to have_content "bitKlavier Grand Sample Library—Binaural Mic Image"
    author_top_of_page = '<span class="author-name">'
    author_popover_title = 'data-original-title="Trueman, Daniel"'
    author_popover_orcid = 'https://orcid.org/1234-1234-1234-1234'
    author_popover_affiliation = "/?f[authors_affiliation_ssim][]=Princeton+Plasma+Physics+Laboratory"
    author_popover_search_orcid = '/?&amp;q=1234-1234-1234-1234&amp;search_field=orcid'
    author_meta = 'Trueman, Daniel (Princeton Plasma Physics Laboratory)'
    expect(page.html.include?(author_top_of_page)).to be true
    expect(page.html.include?(author_popover_title)).to be true
    expect(page.html.include?(author_popover_orcid)).to be true
    expect(page.html.include?(author_popover_search_orcid)).to be true
    expect(page.html.include?(author_popover_affiliation)).to be true
    expect(page.html.include?(author_meta)).to be true
  end
  # rubocop:enable Layout/LineLength

  it "renders collection tags as links" do
    visit '/catalog/doi-10-34770-r75s-9j74'
    tag1 = "<a href=\"/?f[collection_tag_ssim][]=Humanities"
    tag2 = "<a href=\"/?f[collection_tag_ssim][]=Something+else"
    expect(page.html.include?(tag1)).to be true
    expect(page.html.include?(tag2)).to be true
  end

  # rubocop:disable Layout/LineLength
  xit "has expected citation information" do
    visit '/catalog/78348'
    apa_citation = "Stotler, D., F. Scotti, R.E. Bell, A. Diallo, B.P. LeBlanc, M. Podesta, A.L. Roquemore, & P.W. Ross. (2016). Midplane neutral density profiles in the National Spherical Torus Experiment [Data set]. Princeton Plasma Physics Laboratory, Princeton University."
    expect(page).to have_content apa_citation
    expect(page.html.include?('<button id="show-apa-citation-button"')).to be true
    expect(page.html.include?('<button id="show-bibtex-citation-button"')).to be true
  end
  # rubocop:enable Layout/LineLength

  xit "has expected HTML SPAN element with COinS information" do
    visit '/catalog/78348'
    expect(page.html.include?('<span class="Z3988"')).to be true
  end

  xit "renders pageviews and downloads stats" do
    visit '/catalog/78348'
    expect(page.html.include?('<span id="pageviews"')).to be true
    expect(page.html.include?('<span id="downloads"')).to be true
  end

  context "clickable links" do
    let(:globus_download_link) { "https://app.globus.org/file-manager?origin_id=dc43f461-0ca7-4203-848c-33a9fc00a464=%2Fvsj7-4j83%2F" }

    xit "renders hyperlinks in the abstract and description fields" do
      visit '/catalog/78348'
      expect(page.html.include?('<a href="http://torus.example.com">http://torus.example.com</a>')).to be true
      links = page.find("div.document-description").find_all("a").map { |a| a["href"] }
      expect(links.include?(globus_download_link)).to be true
    end
  end
end
