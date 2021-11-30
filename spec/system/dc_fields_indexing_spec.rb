# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
describe 'DataSpace research data all fields indexing', type: :system do
  subject(:result) do
    indexer.map_record(record)
  end
  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Rails.root.join('lib', 'traject', 'dataspace_research_data_config.rb'))
    end
  end
  let(:dspace_xml) do
    File.join(fixture_path, 'single_item_dc_fields_all.xml')
  end
  let(:nokogiri_reader) do
    Traject::NokogiriReader.new(File.read(dspace_xml), indexer.settings)
  end
  let(:records) do
    nokogiri_reader.to_a
  end
  let(:record) do
    records.first
  end

  it 'id' do
    expect(result['id'].first).to eq '96151'
  end

  it 'title' do
    expect(result['title_ssim'].first).to eq 'Sowing the Seeds for More Usable Web Archives: A Usability Study of Archive-It'
  end

  it 'alternative_title' do
    expect(result['alternative_title_ssim'].first).to eq 'Usability Study of Archive-It for Libraries'
  end

  it 'author' do
    expect(result['author_tesim'].first).to eq 'Abrams, Samantha'
  end

  it 'format' do
    expect(result['format_ssim'].first).to eq 'Research paper'
  end

  it 'extent' do
    expect(result['extent_ssim'].first).to eq '45 minutes'
  end

  it 'medium' do
    expect(result['medium_ssim'].first).to eq '45 minutes'
  end

  it 'mimetype' do
    expect(result['mimetype_ssim'].first).to eq 'text/html'
  end

  it 'language' do
    expect(result['language_ssim'].first).to eq 'English'
  end

  it 'publisher' do
    expect(result['publisher_ssim'].first).to eq 'Research Data Publishing Press'
  end

  it 'publisher_place' do
    expect(result['publisher_place_ssim'].first).to eq 'New York, NY, USA'
  end

  it 'publisher_corporate' do
    expect(result['publisher_corporate_ssim'].first).to eq 'Corporate Publishers, Inc.'
  end

  it 'relation' do
    expect(result['relation_ssim'].first).to eq 'Sowing the Seeds for More Usable Web Archives: A Usability Study of Archive-It, Fall/Winter 2019, Vol. 82, No. 2.'
  end

  it 'relation_is_format_of' do
    expect(result['relation_is_format_of_ssim'].first).to eq 'Print version'
  end

  it 'relation_is_part_of' do
    expect(result['relation_is_part_of_ssim'].first).to eq 'Part 1'
  end

  it 'relation_is_part_of_series' do
    expect(result['relation_is_part_of_series_ssim'].first).to eq 'Published Series'
  end

  it 'relation_has_part' do
    expect(result['relation_has_part_ssim'].first).to eq 'Related part'
  end

  it 'relation_is_version_of' do
    expect(result['relation_is_version_of_ssim'].first).to eq 'Original copy with multiple versions'
  end

  it 'relation_has_version' do
    expect(result['relation_has_version_ssim'].first).to eq 'Version 2'
  end

  it 'relation_is_based_on' do
    expect(result['relation_is_based_on_ssim'].first).to eq 'Original content'
  end

  it 'relation_is_referenced_by' do
    expect(result['relation_is_referenced_by_ssim'].first).to eq 'Other publication'
  end

  it 'relation_requires' do
    expect(result['relation_requires_ssim'].first).to eq 'Required object'
  end

  it 'relation_replaces' do
    expect(result['relation_replaces_ssim'].first).to eq 'Older version'
  end

  it 'relation_is_replaced_by' do
    expect(result['relation_is_replaced_by_ssim'].first).to eq 'Replacement copy'
  end

  it 'relation_uri' do
    expect(result['relation_uri_ssim'].first).to eq 'https://ezid.cdlib.org/id/ark:/99999/fk4806k254'
  end

  # rubocop:disable Layout/LineLength
  it 'rights' do
    expect(result['rights_ssim'].first).to eq 'Example text - RightsStatements.org provides a set of standardized rights statements that can be used to communicate the copyright and re-use status of digital objects to the public. Our rights statements are supported by major aggregation platforms such as the Digital Public Library of America and Europeana. The rights statements have been designed with both human users and machine users (such as search engines) in mind and make use of semantic web technology.'
  end
  # rubocop:enable Layout/LineLength

  it 'rights_uri' do
    expect(result['rights_uri_ssim'].first).to eq 'https://rightsstatements.org'
  end

  it 'rights_holder' do
    expect(result['rights_holder_ssim'].first).to eq 'Samantha Abrams'
  end

  it 'access_rights' do
    expect(result['access_rights_ssim'].first).to eq 'Terms of access rights'
  end

  it 'license' do
    expect(result['license_ssim'].first).to eq 'CC0 License'
  end

  it 'spatial' do
    expect(result['spatial_coverage_tesim'].first).to eq 'North Decimal Degree 40.405833. South Decimal Degree 40.268333. East Decimal Degree -74.569167. West Decimal Degree -74.747222.'
  end

  it 'temporal' do
    expect(result['temporal_coverage_tesim'].first).to eq 'Start date 2014-01-01'
  end

  it 'subject' do
    expect(result['subject_tesim'].first).to eq 'Web archiving'
  end

  it 'subject_classification' do
    expect(result['subject_classification_tesim'].first).to eq 'Classification system'
  end

  it 'subject_ddc' do
    expect(result['subject_ddc_tesim'].first).to eq '006.7 Multimedia systems -- Information Architecture'
  end

  it 'subject_lcc' do
    expect(result['subject_lcc_tesim'].first).to eq 'T173.2-174.5'
  end

  it 'subject_lcsh' do
    expect(result['subject_lcsh_tesim'].first).to eq 'World Wide Web pages'
  end

  it 'subject_mesh' do
    expect(result['subject_mesh_tesim'].first).to eq 'A18 Plant Structures'
  end

  it 'subject_other' do
    expect(result['subject_other_tesim'].first).to eq 'Web archiving portals'
  end

  it 'genre' do
    expect(result['genre_ssim'].first).to eq 'Dataset'
  end

  it 'peer_review_status' do
    expect(result['peer_review_status_ssim'].first).to eq 'Reviewed'
  end

  it 'translator' do
    expect(result['translator_ssim'].first).to eq 'Jane Smith'
  end

  it 'isan' do
    expect(result['isan_ssim'].first).to eq 'ISAN 0000-0000-3A8D-0000-Z-0000-0000-6'
  end

  it 'provenance' do
    expect(result['provenance_ssim'].first).to eq 'Provenance information for this version'
  end

  it 'funding_agency' do
    expect(result['funding_agency_ssim'].first).to eq 'Funding Agency, Inc.'
  end
end
# rubocop:enable Metrics/BlockLength
