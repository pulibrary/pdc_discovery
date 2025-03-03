# frozen_string_literal: true
require 'rails_helper'

describe 'Single item page', type: :system, js: true do
  before do
    load_describe_small_data
  end

  it "has expected header fields" do
    visit '/catalog/doi-10-34770-r75s-9j74'
    expect(page).to have_css '.document-title-heading'
    expect(page).to have_css '.authors-heading'
    expect(page).to have_css 'div.authors-heading > span.author-name'
    expect(page).to have_css '.issue-date-heading'
  end

  # rubocop:disable RSpec/ExampleLength
  it "has expected metadata" do
    visit '/catalog/doi-10-34770-00yp-2w12'
    expect(page).to have_content "Sowing the Seeds for More Usable Web Archives: A Usability Study of Archive-It"
    find('#show-more-metadata-link').click
    authors = ['<span class="author-name">Abrams, Samantha;</span>']
    authors << '<span class="author-name">Antracoli, Alexis;</span>'
    authors << '<span class="author-name">Appel, Rachel;</span>'
    authors << '<span class="author-name">Caust-Ellenbogen, Celia;</span>'
    authors << '<span class="author-name">Dennison, Sarah;</span>'
    authors << '<span class="author-name">Duncan, Sumitra;</span>'
    authors << '<span class="author-name">Ramsay, Stefanie</span>'
    authors.each do |value|
      expect(page.html.include?(value)).to be true
    end
  end
  # rubocop:enable RSpec/ExampleLength

  # rubocop:disable Layout/LineLength
  it "has expected citation information" do
    visit '/catalog/doi-10-34770-00yp-2w12'
    apa_citation = "Abrams, Samantha, Antracoli, Alexis, Appel, Rachel, Caust-Ellenbogen, Celia, Dennison, Sarah, Duncan, Sumitra, & Ramsay, Stefanie. (2023). Sowing the Seeds for More Usable Web Archives: A Usability Study of Archive-It [Data set]. Princeton University."
    expect(page).to have_content apa_citation
    expect(page.html.include?('<button id="show-apa-citation-button"')).to be true
    expect(page.html.include?('<button id="show-bibtex-citation-button"')).to be true
  end
  # rubocop:enable Layout/LineLength

  it "has expected HTML SPAN element with COinS information" do
    visit '/catalog/doi-10-34770-00yp-2w12'
    expect(page.html.include?('<span class="Z3988"')).to be true
  end

  it "renders pageviews and downloads stats" do
    visit '/catalog/doi-10-34770-00yp-2w12'
    expect(page.html.include?('<span id="pageviews"')).to be true
    expect(page.html.include?('<span id="downloads"')).to be true
  end

  context "clickable links" do
    let(:globus_download_link) { "https://app.globus.org/file-manager?origin_id=dc43f461-0ca7-4203-848c-33a9fc00a464=%2Fvsj7-4j83%2F" }

    it "renders hyperlinks in the abstract and description fields" do
      visit '/catalog/doi-10-34770-00yp-2w12'
      expect(page.html.include?('<a href="http://torus.example.com">http://torus.example.com</a>')).to be true
    end
  end
end
