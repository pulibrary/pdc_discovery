# frozen_string_literal: true
require 'rails_helper'

# As a submitter/depositor, I need my draft DOI to resolve to a landing page,
# so that when I include the draft DOI in a citation in a draft paper,
# my readers and reviewers can see that the link is not broken--just pending publication.
describe 'When a PDC Work has not yet been published', type: :system, js: true do
  before do
    # Run the indexer to add the draft doi test documents to Solr
    load_describe_draft_dois
  end

  it "renders a page with the DOI and some placeholder information" do
    true
  end
end
