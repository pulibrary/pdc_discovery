# frozen_string_literal: true

describe 'Embargoed Document page', type: :system, js: true do
  context "when the Solr Document has an embargo date" do
    # This redundancy is required for consistent testing
    let(:embargo_resource) { item_file_fixture.read }
    let(:rss_feed) { file_fixture("works.rss").read }
    let(:rss_url) { "https://pdc-describe-prod.princeton.edu/describe/works.rss" }
    let(:indexer) { DescribeIndexer.new(rss_url: rss_url) }
    let(:solr_response) do
      Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
    end

    before do
      stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works.rss")
        .to_return(status: 200, body: rss_feed, headers: {})
      stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works/6.json")
        .to_return(status: 200, body: embargo_resource, headers: {})
      stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works/20.json")
        .to_return(status: 200, body: embargo_resource, headers: {})

      Blacklight.default_index.connection.delete_by_query("*:*")
      Blacklight.default_index.connection.commit
      indexer.index
    end

    context "and the PDC Describe Work is under active embargo" do
      let(:document_id) { "doi-10-34770-r75s-9j74-active-embargo" }
      let(:item_file_fixture) { file_fixture("pdc_describe_active_embargo.json") }
      it "renders a message to the client expressing this and detailing the embargo date" do
        visit "/catalog/#{document_id}"
        embargo_message_included = page.html.include?("File(s) associated with this object are embargoed until 2033-09-13.")
        expect(embargo_message_included).to be true
      end
    end

    context "and the PDC Describe Work is under an expired embargo" do
      let(:document_id) { "doi-10-34770-r75s-9j74-expired-embargo" }
      let(:item_file_fixture) { file_fixture("pdc_describe_expired_embargo.json") }
      it "does not render the embargo message" do
        visit "/catalog/#{document_id}"
        embargo_message_included = page.html.include?("File(s) associated with this object are embargoed until 2033-09-13T00:00:00Z.")
        expect(embargo_message_included).not_to be true
      end
    end
  end
end
