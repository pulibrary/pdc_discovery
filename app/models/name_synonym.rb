# frozen_string_literal: true

class NameSynonym
  class << self
    def build_solr_synonym_file(synonym_file_name)
      File.open(synonym_file_name, "w") do |file|
        file.puts("# NOTE!!!")
        file.puts("# This file was automatically generates by running: bundle exec rake names:synonyms ")
        file.puts("# !!!!")
        synonyms_from_wiki.each do |synonym|
          file.puts(synonym)
        end
      end
    end

    private

    def synonyms_from_wiki
      url = 'https://en.wiktionary.org/w/api.php?action=parse&page=Appendix:English_given_names&prop=wikitext&format=json'
      uri = URI(url)
      response = Net::HTTP.get(uri)
      json_data = JSON.parse(response)
      page_parts = json_data["parse"]["wikitext"]["*"].split("\n\n")
      name_parts = page_parts.select { |part| part.starts_with?(/===[A-Z]===/) }
      name_parts.map do |name_part|
        name_strings = name_part.split("\n")
        name_strings.map do |name_str|
          next if name_str.starts_with?("===")
          clean_name(name_str)
        end
      end.flatten.compact
    end

    def clean_name(name_str)
      names = name_str.split(" - ")
      clean_key = names.first[/\[\[(.*)\]\]/, 1]
      list = [clean_key] + synonym_list(names.last)
      list.map(&:strip).compact.map(&:downcase).join(",")
    end

    def synonym_list(list_str)
      names = list_str.split(", ")
      names.map do |name|
        if name.include?(' (')
          name.split(' (').map { |paren_name| paren_name.delete(")") }
        else
          name
        end
      end.flatten
    end
  end
end
