# frozen_string_literal: true

describe 'Application landing page', type: :system, js: true do
  let(:feed_docs) do
    docs = []
    docs << SolrDocument.new({ id: "84912", genre_ssim: ["Dataset"], pdc_created_at_dtsi: '1995-12-31T23:59:59Z', title_tesim: ['1995 Title'] })
    docs << SolrDocument.new({ id: "90553", genre_ssim: ["moving image"], pdc_created_at_dtsi: '1996-12-31T23:59:59Z', title_tesim: ['1996 Title'] })
    docs << SolrDocument.new({ id: "84484", genre_ssim: [nil], pdc_created_at_dtsi: '1997-12-31T23:59:59Z', title_tesim: ['1997 Title'] })
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

  it "sorts recently added items by date" do
    allow(RecentlyAdded).to receive(:feed).and_return(feed_docs)
    visit '/'
    first_title = find(:css, "ul#recently-added>li:first-of-type>span.title").text
    expect(first_title).to eq "1997 Title"
  end
end
