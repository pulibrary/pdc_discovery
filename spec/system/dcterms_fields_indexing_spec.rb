# frozen_string_literal: true
require 'rails_helper'

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
    File.join(fixture_path, 'single_item_dcterms_fields_all.xml')
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
    expect(result['id'].first).to eq '84192'
  end

  it 'title' do
    expect(result['title_tesim'].first).to eq 'Subject Liaisons in Academic Libraries: An Open Access Data Set from 2015'
  end

  # rubocop:disable Layout/LineLength
  it 'abstract' do
    expect(result['abstract_tsim'].first).to eq 'The work of subject liaison librarians in academic libraries has morphed to include a variety of roles that reach beyond the traditional. This study captures responses of 1,808 participants from land-grant, Oberlin Group, and Association of Research Libraries (ARL) institutions to a questionnaire about subject liaison librarians. The questionnaire contains eight demographic questions, five questions about liaison responsibilities, seven outreach and instruction questions, three traditional reference questions, two scholarly communications questions, three collection development questions, and an open-ended question. This is the largest data set compiled to date on academic subject liaison librarians. The data set has been made available on an open access basis in hopes that use of the data will facilitate cross-study comparisons.'
  end
  # rubocop:enable Layout/LineLength

  it 'access_rights' do
    expect(result['access_rights_ssim'].first).to eq 'Sample access rights statement version 2'
  end

  it 'accrual_method' do
    expect(result['accrual_method_ssim'].first).to eq 'Item Creation'
  end

  it 'accrual_periodicity' do
    expect(result['accrual_periodicity_ssim'].first).to eq 'Triennial'
  end

  it 'accrual_policy' do
    expect(result['accrual_policy_ssim'].first).to eq 'Active'
  end

  it 'alternative_title' do
    expect(result['alternative_title_tesim'].first).to eq 'Subject Liaisons in Academic Libraries'
  end

  it 'audience' do
    expect(result['audience_ssim'].first).to eq 'Researchers'
  end

  it 'available' do
    expect(result['available_ssim'].first).to eq '2015 - present'
  end

  it 'bibliographic_citation' do
    expect(result['bibliographic_citation_ssim'].first).to eq 'Nero, Neil. Subject Liaisons in Academic Libraries: An Open Access Data Set from 2015. [New York, NY, n.c.]'
  end

  it 'conforms_to' do
    expect(result['conforms_to_ssim'].first).to eq 'https://www.w3.org/2005/sparql-results'
  end

  it 'contributor' do
    expect(result['contributor_tsim'].first).to eq 'Smith, Jane'
  end

  it 'coverage' do
    expect(result['coverage_tesim'].first).to eq 'Princeton, NJ, USA'
  end

  it 'created' do
    expect(result['date_created_ssim'].first).to eq '1 October 2015'
  end

  it 'creator' do
    expect(result['creator_tesim'].first).to eq 'Nero, Neil'
  end

  it 'date_accepted' do
    expect(result['date_accepted_ssim'].first).to eq '2015/11/15'
  end

  it 'copyright_date' do
    expect(result['copyright_date_ssim'].first).to eq '2021/01/01'
  end

  it 'date_submitted' do
    expect(result['date_submitted_ssim'].first).to eq '10/2015'
  end

  it 'date' do
    expect(result['date_ssim'].first).to eq '2021'
  end

  it 'description' do
    expect(result['description_tsim'].first).to eq 'Submitted by Neil Nero on 2016-09-28T19:46:34Z No. of bitstreams: 2'
  end

  it 'education_level' do
    expect(result['education_level_ssim'].first).to eq 'Education level value'
  end

  it 'extent' do
    expect(result['extent_ssim'].first).to eq '21 minutes'
  end

  it 'format' do
    expect(result['format_ssim'].first).to eq 'text:pdf'
  end

  it 'relation_has_format' do
    expect(result['relation_has_format_ssim'].first).to eq 'text:html'
  end

  it 'relation_has_part' do
    expect(result['relation_has_part_ssim'].first).to eq 'Subject librarians listing'
  end

  it 'relation_has_version' do
    expect(result['relation_has_version_ssim'].first).to eq 'Abridged directory listing'
  end

  it 'other_identifier' do
    expect(result['other_identifier_ssim'].first).to eq 'http://arks.princeton.edu/ark:/88435/dsp01v405sc863'
  end

  it 'instructional_method' do
    expect(result['instructional_method_ssim'].first).to eq 'Direct instruction'
  end

  it 'relation_is_format_of' do
    expect(result['relation_is_format_of_ssim'].first).to eq 'HTML version of original'
  end

  it 'relation_is_part_of' do
    expect(result['relation_is_part_of_ssim'].first).to eq 'Librarian research compendium'
  end

  it 'relation_is_referenced_by' do
    expect(result['relation_is_referenced_by_ssim'].first).to eq 'Librarian Directory 2016'
  end

  it 'relation_is_replaced_by' do
    expect(result['relation_is_replaced_by_ssim'].first).to eq 'Sample replacement data'
  end

  it 'relation_is_required_by' do
    expect(result['relation_is_required_by_ssim'].first).to eq 'Sample requirement data'
  end

  it 'relation_is_version_of' do
    expect(result['relation_is_version_of_ssim'].first).to eq 'Librarian Compendium, 2014'
  end

  it 'issue_date' do
    expect(result['issue_date_ssim'].first).to eq 'January 2017'
  end

  it 'language' do
    expect(result['language_ssim'].first).to eq 'English'
  end

  it 'license' do
    expect(result['license_ssim'].first).to eq 'Example license info'
  end

  it 'mediator' do
    expect(result['mediator_ssim'].first).to eq 'Example Mediators, Inc.'
  end

  it 'medium' do
    expect(result['medium_ssim'].first).to eq 'Digital'
  end

  it 'date_modified' do
    expect(result['date_modified_ssim'].first).to eq '2015/10/05'
  end

  it 'provenance' do
    expect(result['provenance_ssim'].first).to eq 'Example provenance information for PUL'
  end

  it 'publisher' do
    expect(result['publisher_ssim'].first).to eq 'Research Data Publishers'
  end

  it 'referenced_by' do
    expect(result['referenced_by_ssim'].first).to eq 'https://ezid.cdlib.org/id/ark:/99999/fk4vh7115f'
  end

  it 'relation' do
    expect(result['relation_ssim'].first).to eq 'Librarians and Libraries, 2015'
  end

  it 'relation_replaces' do
    expect(result['relation_replaces_ssim'].first).to eq 'Librarian Directory, 2014'
  end

  it 'relation_requires' do
    expect(result['relation_requires_ssim'].first).to eq 'Librarians and Libraries Glossary'
  end

  it 'rights_holder' do
    expect(result['rights_holder_ssim'].first).to eq 'Anne Langley and Neil Nero'
  end

  # rubocop:disable Layout/LineLength
  it 'rights' do
    expect(result['rights_ssim'].first).to eq 'Sample rights statement - RightsStatements.org provides a set of standardized rights statements that can be used to communicate the copyright and re-use status of digital objects to the public. Our rights statements are supported by major aggregation platforms such as the Digital Public Library of America and Europeana. The rights statements have been designed with both human users and machine users (such as search engines) in mind and make use of semantic web technology. Learn more about how you can use our rights statements here.'
  end
  # rubocop:enable Layout/LineLength

  it 'source' do
    expect(result['source_ssim'].first).to eq 'https://ezid.cdlib.org/id/ark:/99999/fk4qr69706'
  end

  it 'subject' do
    expect(result['subject_tesim'].first).to eq 'Open Access'
  end

  it 'spatial_coverage' do
    expect(result['spatial_coverage_tesim'].first).to eq 'North Decimal Degree 40.405833. South Decimal Degree 40.268333. East Decimal Degree -74.569167. West Decimal Degree -74.747222.'
  end

  it 'table_of_contents' do
    expect(result['tableofcontents_tesim'].first).to eq 'ToC Summary'
  end

  it 'temporal' do
    expect(result['temporal_coverage_tesim'].first).to eq 'Start date: 2015-02-01'
  end

  it 'genre' do
    expect(result['genre_ssim'].first).to eq 'Dataset'
  end

  it 'date_valid' do
    expect(result['date_valid_ssim'].first).to eq '2015 - 2021'
  end
end
# rubocop:enable Metrics/BlockLength
