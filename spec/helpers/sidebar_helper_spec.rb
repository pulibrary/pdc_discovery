# frozen_string_literal: true

RSpec.describe SidebarHelper, type: :helper do
  describe "#render_sidebar_related_identifiers" do
    let(:text_id) { {"related_identifier" => "123", "relation_type" => "IsCitedBy"}}
    let(:link_id) { {"related_identifier" => "http://abc.org/999", "relation_type" => "IsCitedBy"}}
    let(:bad_id1) { {"related_identifier" => nil, "relation_type" => "badid"}}
    let(:bad_id2) { {"related_identifier" => "badid", "relation_type" => nil}}
    let(:identifiers) { [text_id, link_id, bad_id1, bad_id2]}
    let(:html) { helper.render_sidebar_related_identifiers("Related Identifiers", identifiers) }

    it "titleize relation type" do
      expect(html.include?("Is Cited By")).to be true
    end

    it "URLs are rendered as links" do
      expect(html.include?("<a href=http://abc.org/999")).to be true
    end

    it "ignores bad identifiers" do
      expect(html.include?("badid")).to be false
    end
  end
end
