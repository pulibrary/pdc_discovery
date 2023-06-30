# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  describe "#render_field_row_search_link" do
    let(:title) { "Domain" }
    let(:value) { "Humanities" }
    let(:field) { "domain_ssim," }
    let(:search_link) { helper.search_link(value, field) }
    let(:rendered_search_link) { helper.render_field_row_search_link(title, value, field) }

    it "creates a search link" do
      expect(rendered_search_link).to match(title)
      expect(rendered_search_link).to match(value)
      expect(rendered_search_link).to match(field)
    end

    # config.assets.prefix = "/discovery/assets/"
    context "when there is an assets prefix" do
      around do |example|
        Rails.application.config.assets.prefix = "/discovery/assets/"
        example.run
        Rails.application.config.assets.prefix = "/assets/"
      end

      it "pre-pends the link" do
        expect(search_link).to eq "/discovery/?f[domain_ssim][]=Humanities&q=&search_field=all_fields"
      end
    end

    context "when there is not an assets prefix" do
      it "does not pre-pend the link" do
        expect(search_link).to eq "/?f[domain_ssim][]=Humanities&q=&search_field=all_fields"
      end
    end
  end
end
