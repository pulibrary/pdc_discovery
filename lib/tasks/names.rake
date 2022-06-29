# frozen_string_literal: true

namespace :names do
  desc 'Parses The name wiki page and stores the results in the solr/conf/name-synonyms.txt'
  task synonyms: :environment do
    synonym_file = Rails.root.join('solr', 'conf', 'name-synonyms.txt')
    NameSynonym.build_solr_synonym_file(synonym_file)
  end
end
