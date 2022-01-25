# frozen_string_literal: true
require "rails_helper"

describe "accessibility", type: :system, js: true do
  before do
    stub_request(:get, "https://github.com/mozilla/geckodriver/releases/latest").
    with(
      headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Host'=>'github.com',
        'User-Agent'=>'Ruby'
      }
    )
  end
  context "homepage" do
    it "complies with ..." do
      visit "/"
      expect(page).to be_axe_clean
    end
  end
end
