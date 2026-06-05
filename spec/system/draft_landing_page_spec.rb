# frozen_string_literal: true
require 'rails_helper'

describe 'Landing page for draft works', type: :system, js: true do
  let(:draft_work) { file_fixture("pdc_describe_draft.json").read }

  before do
    load_describe_dataset
  end

  it "renders draft works landing page" do
    # This DOI (10.80021/t4ef-kr07) is of a Work that is in the draft state
    visit '/catalog/doi-10-80021-t4ef-kr07'
    expect(page).to have_content "Publication Pending"
  end
end
