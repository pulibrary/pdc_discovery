# frozen_string_literal: true
module Indexing
  # Derives domain for a record from a list of communities
  #
  # At some point this class might need to be enhanced to determine the "main"
  # domain from a list communities considering the parent/child relationship
  # among them, but for now we don't need that logic.
  class Domain
    def self.from_communities(communities)
      communities.map { |community| from_community(community) }.uniq.compact
    end

    def self.from_community(community)
      item = community_mappings.find { |mapping| mapping[:community] == community } || {}
      item[:domain]
    end

    # Mapping between communities and domains found on this document
    # https://docs.google.com/spreadsheets/d/1J7qQtLjSvC87pW1UzHhsQ4Te8tRaUJkxqAoU8luXTqo/edit#gid=0
    def self.community_mappings
      @community_mappings ||= begin
        mappings = []
        mappings << { community: "Computational Social Science", domain: "Social Sciences" }
        mappings << { community: "Department of Geosciences", domain: "Natural Sciences" }
        mappings << { community: "Department of Slavic Languages and Literatures", domain: "Humanities" }
        mappings << { community: "Digital Humanities", domain: "Humanities" }
        mappings << { community: "Economics", domain: "Social Sciences" }
        mappings << { community: "Education Research Section", domain: "Social Sciences" }
        mappings << { community: "Electrical Engineering", domain: "Engineering" }
        mappings << { community: "Faculty Publications", domain: nil }
        mappings << { community: "Geophysical Fluid Dynamics Laboratory", domain: "Natural Sciences" }
        mappings << { community: "Industrial Relations Section", domain:	"Social Sciences" }
        mappings << { community: "Lewis-Sigler Institute for Integrative Genomics", domain: "Natural Sciences" }
        mappings << { community: "Liechtenstein Institute for Self-Determination", domain: "Social Sciences" }
        mappings << { community: "Mechanical and Aerospace Engineering", domain:	"Engineering" }
        mappings << { community: "Molecular Biology", domain: "Natural Sciences" }
        mappings << { community: "Music and Arts", domain: "Humanities" }
        mappings << { community: "Office of Information Technology", domain: nil }
        mappings << { community: "Physics", domain: "Natural Sciences" }
        mappings << { community: "Princeton Neuroscience Institute", domain:	"Natural Sciences" }
        mappings << { community: "Princeton Plasma Physics Laboratory", domain: "Natural Sciences" }
        mappings << { community: "Princeton School of Public and International Affairs", domain:	"Social Sciences" }
        mappings << { community: "Princeton University Doctoral Dissertations, 2011-2021", domain: nil }
        mappings << { community: "Princeton University Library", domain:	"Humanities" }
        mappings << { community: "Princeton University Undergraduate Senior Theses, 1924-2021", domain: nil }
        mappings << { community: "Seeger Center for Hellenic Studies", domain: "Humanities" }
        mappings << { community: "Sociology", domain: "Social Sciences" }
        mappings
      end
    end
  end
end
