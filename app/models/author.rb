# frozen_string_literal: true

class Author
  attr_reader :value, :name_type, :given_name, :family_name, :identifier, :affiliation, :sequence
  def initialize(hash)
    @value = hash["value"]
    @name_type = hash["name_type"]
    @given_name = hash["given_name"]
    @family_name = hash["family_name"]
    @identifier = hash["identifier"]
    @affiliation = hash["affiliations"] ? hash["affiliations"].first : nil
    @sequence = hash["sequence"] || 0
  end

  def affiliation_name
    @affiliation&.fetch("value", nil)
  end

  def affiliation_index
    if @affiliation
      @affiliation.fetch("index", 0)
    else
      0
    end
  end

  def affiliation_index=(index)
    if @affiliation
      @affiliation["index"] = index
    end
  end
end
