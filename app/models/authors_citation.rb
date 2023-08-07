# frozen_string_literal: true

class AuthorsCitation
  attr_reader :authors

  def initialize(authors)
    @authors = authors
    set_affiliation_index
  end

  # Set the index affiliation for the set of authors
  def set_affiliation_index
    orgs = @authors.map(&:affiliation_name).compact.uniq
    indexed_orgs = []
    orgs.each_with_index do |name, index|
      indexed_orgs << { name: name, index: index + 1 }
    end

    @authors.each do |author|
      author_org = author.affiliation_name
      if author_org
        indexed_org = indexed_orgs.find { |org| org[:name] == author_org }
        author.affiliation_index = indexed_org[:index]
      else
        author.affiliation_index = 0
      end
    end
  end
end
