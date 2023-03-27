# frozen_string_literal: true

describe 'Application landing page', type: :system do
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
    expect(page).to have_link "How to Submit", href: "/submit"
    expect(page).to have_link "Accessibility", href: "https://accessibility.princeton.edu/help"
  end
end
