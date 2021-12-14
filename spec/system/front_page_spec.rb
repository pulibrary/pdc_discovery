# frozen_string_literal: true

describe 'Application landing page', type: :system do
  describe "icons for recently added items" do
    # Notice that I split the recently added feed into two groups of 5 because
    # the page limits the amount of items to display to at most 5 and we have
    # more than 5 icons to test.
    let(:feed_docs_1) do
      docs = []
      docs << SolrDocument.new({ id: "84912", genre_ssim: ["Dataset"] })
      docs << SolrDocument.new({ id: "90553", genre_ssim: ["moving image"] })
      docs << SolrDocument.new({ id: "85707", genre_ssim: ["software"] })
      docs << SolrDocument.new({ id: "88912", genre_ssim: ["image"] })
      docs << SolrDocument.new({ id: "88970", genre_ssim: ["text"] })
    end

    let(:feed_docs_2) do
      docs = []
      docs << SolrDocument.new({ id: "80489", genre_ssim: ["collection"] })
      docs << SolrDocument.new({ id: "87751", genre_ssim: ["article"] })
      docs << SolrDocument.new({ id: "78348", genre_ssim: ["interactive resource"] })
      docs << SolrDocument.new({ id: "84484", genre_ssim: [nil] })
      docs
    end

    # rubocop:disable RSpec/ExampleLength
    it "renders Bootstrap icons for Recently added feed (part 1)" do
      allow(RecentlyAdded).to receive(:feed).and_return(feed_docs_1)
      visit '/'
      expect(page).to have_css 'li#recently-added-84912 i.bi-stack'
      expect(page).to have_css 'li#recently-added-90553 i.bi-film'
      expect(page).to have_css 'li#recently-added-85707 i.bi-code-slash'
      expect(page).to have_css 'li#recently-added-88912 i.bi-image'
      expect(page).to have_css 'li#recently-added-88970 i.bi-card-text'
    end
    # rubocop:enable RSpec/ExampleLength

    # rubocop:disable RSpec/ExampleLength
    it "renders Bootstrap icons for Recently added feed (part 2)" do
      allow(RecentlyAdded).to receive(:feed).and_return(feed_docs_2)
      visit '/'
      expect(page).to have_css 'li#recently-added-80489 i.bi-collection-fill'
      expect(page).to have_css 'li#recently-added-87751 i.bi-journal-text'
      expect(page).to have_css 'li#recently-added-78348 i.bi-pc-display-horizontal'
      expect(page).to have_css 'li#recently-added-84484 i.bi-file-earmark-fill'
    end
    # rubocop:enable RSpec/ExampleLength
  end

  it "has a footer with latest deploy information" do
    visit '/'
    expect(page).to have_content "last updated"
  end
end
