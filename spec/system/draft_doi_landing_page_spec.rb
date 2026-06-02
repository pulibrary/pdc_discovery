# frozen_string_literal: true
require 'rails_helper'

describe 'Landing page for draft DOI', type: :system, js: true do
  let(:rss_feed) { file_fixture("pdc_describe_feeds/works.rss").read }

  before do
    load_describe_dataset
  end

  it "renders draft DOI works landing page" do
    # This DOI (10.34770/14zc-5c22) is of a draft Work
    visit '/catalog/doi-10-34770-14zc-5c22'
    expect(page).to have_content 'Publication Pending'
  end

end