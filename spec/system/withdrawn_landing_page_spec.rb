# frozen_string_literal: true
require 'rails_helper'

describe 'Landing page for withdrawn works', type: :system, js: true do
  let(:withdrawn_work) { file_fixture("pdc_describe_withdrawn.json").read }

  before do
    load_describe_dataset
  end

  it "renders withdrawn works landing page" do
    # This DOI (10.80021/bsdz-he25) is of a Work that has been withdrawn
    visit '/catalog/doi-10-80021-bsdz-he25'
    find('a[href="https://doi.org/10.80021/bsdz-he25"]').click
  end
end