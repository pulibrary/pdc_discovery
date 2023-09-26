# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  describe "#render_field_row_search_link" do
    let(:title) { "Domain" }
    let(:value) { "Humanities" }
    let(:field) { "domain_ssim" }
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

  describe "#render_funders" do
    it "does not render if there are no funders" do
      expect(render_funders([])).to be nil
      expect(render_funders(nil)).to be nil
    end
  end

  describe "#render_funder" do
    it "renders names as hyperlinks when there is an ROR" do
      funder = { 'ror' => "http://ror.org/123", 'name' => "some funding organization" }
      expected_link = '<a href="/?f[http://ror.org/123]'
      expect(render_funder(funder).include?(expected_link)).to be true
    end

    it "renders names as text when there is no ROR" do
      funder = { 'name' => "some funding organization" }
      expect(render_funder(funder).include?("<a href")).to be false
    end

    it "renders award as link when there is a URI" do
      funder = { 'name' => "name", 'award_number' => '123', 'award_uri' => "http://nsf/123" }
      expected_link = '<a href="http://nsf/123'
      expect(render_funder(funder).include?(expected_link)).to be true
    end

    it "renders award as text when there is no URI" do
      funder = { 'name' => 'some funding organization', 'award_number' => '123' }
      expect(render_funder(funder).include?("<a href")).to be false
    end

    it "concatenates name and award when both are available" do
      funder = { 'name' => "name", 'award_number' => '123' }
      expect(render_funder(funder)).to eq "name, 123"
    end

    it "displays only funder name when no award information is available" do
      funder = { 'name' => 'some funding organization' }
      expect(render_funder(funder)).to eq "some funding organization"
    end
  end
end
