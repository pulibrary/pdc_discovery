# frozen_string_literal: true
require 'rails_helper'

describe 'Application landing page', type: :system do
  context "checking the page structure" do
    let(:feed_docs) do
      docs = []
      docs << SolrDocument.new({ id: "84912", genre_ssim: ["Dataset"] })
      docs << SolrDocument.new({ id: "90553", genre_ssim: ["moving image"] })
      docs << SolrDocument.new({ id: "84484", genre_ssim: [nil] })
    end

    it "renders Bootstrap icons for Recently added feed items" do
      allow(RecentlyAdded).to receive(:feed).and_return(feed_docs)
      visit '/'
      expect(page).to have_css 'li#recently-added-84912 i.bi-stack'
      expect(page).to have_css 'li#recently-added-90553 i.bi-film'
      expect(page).to have_css 'li#recently-added-84484 i.bi-file-earmark-fill'
    end

    it "has a footer with latest deploy information" do
      visit '/'
      expect(page).to have_content "last updated"
    end

    it "has a header with links to helpful info" do
      visit '/'
      expect(page).to have_link "Home", href: "/"
      expect(page).to have_link "About", href: "/about"
      expect(page).to have_link "How to Submit", href: "https://datacommons.princeton.edu/describe/"
      expect(page).to have_link "Accessibility", href: "https://accessibility.princeton.edu/help"
    end
  end
  context "ordering of recently added items" do
    let(:item1) { file_fixture("pppl1.json").read }
    let(:item2) { file_fixture("pppl2.json").read }
    let(:item3) { file_fixture("pppl3.json").read }
    let(:indexer) do
      DescribeIndexer.new(rss_url: "file://whatever.rss")
    end
    let(:indexed_record) do
      response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
      response["response"]["docs"].first
    end
    before do
      Blacklight.default_index.connection.delete_by_query("*:*")
      Blacklight.default_index.connection.commit
      indexer.index_one(item1)
      indexer.index_one(item2)
      indexer.index_one(item3)
    end
    it "sorts most recent first by created_at date" do
      visit '/'
      first_title = find(:css, "ul#recently-added>li:first-of-type>span.title").text
      expect(first_title).to eq "Lower Hybrid Drift Waves During Guide Field Reconnection"
    end
  end

  context "Contact Us" do
    it "sends emails", js: true do
      visit "/"
      click_on "Contact Us"
      fill_in "feedback", with: "ha ha ha"
      fill_in "name", with: "somebody's name"
      fill_in "email", with: "somebody@gmail.com"
      fill_in "comment", with: "this is a message"
      click_on "Send"
      expect(page.html.include?("We have sent your message to our team")).to be true
      # TODO: Detect that email was sent
    end
  end
end
