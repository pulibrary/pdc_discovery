def load_describe_small_data
    resource1 = file_fixture("sowing_the_seeds.json").read
    bitklavier_binaural_json =  file_fixture("bitklavier_binaural.json").read
    rss_feed =  file_fixture("works.rss").read
    rss_url_string = "https://pdc-describe-prod.princeton.edu/describe/works.rss"
    indexer = DescribeIndexer.new(rss_url: rss_url_string)
    indexer.delete!(query: "*:*")
  

    stub_request(:get, rss_url_string)
        .to_return(status: 200, body: rss_feed)
    stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works/6.json")
        .to_return(status: 200, body: resource1, headers: {})
    stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works/20.json")
        .to_return(status: 200, body: bitklavier_binaural_json, headers: {})
  
    indexer.index

    indexer
end

def load_describe_dataset
    pdc_files = Dir.entries(Rails.root.join("spec", "fixtures", "files", "pdc_describe_data", ""))
                   .reject { |name| [".", "..", "works.rss"].include?(name) }
    pdc_files.each do |name|
      stub_request(:get, "https://datacommons.princeton.edu/describe/works/#{name}")
        .to_return(status: 200, body: File.open(Rails.root.join("spec/fixtures/files/pdc_describe_data/#{name}")).read, headers: {})
    end
    stub_request(:get, "http://pdc_test_data/works.rss")
      .to_return(status: 200, body: File.open(Rails.root.join("spec", "fixtures", "files", "pdc_describe_data", "works.rss")).read, headers: {})
    indexer = DescribeIndexer.new(rss_url: "http://pdc_test_data/works.rss")
    indexer.delete!(query: "*:*")

    indexer.index
    
    indexer
end