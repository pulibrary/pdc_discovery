# frozen_string_literal: true

require "httparty"
require "json"

# Fetches information about Communities (and collections)
# and handles the nested structure of Communities.
#
# rubocop:disable Style/Next
class DataspaceCommunities
  attr_reader :tree

  # @param filename [<String>] File name with communities information cached from DataSpace (used for testing).
  # Fetches data from DataSpace directly when no filename is provided.
  def initialize(filename = nil)
    @tree = []
    @flat_list = nil
    if filename.blank?
      load_from_dataspace
    else
      load_from_file(filename)
    end
  end

  # Returns community information for a given ID
  # @param id [<Int>] ID of the community.
  def find_by_id(id)
    flat_list.find { |community| community.id == id }
  end

  # Returns the name of the root community for given community ID.
  # @param id [<Int>] ID of the community.
  def find_root_name(id)
    root_id = find_path_ids(id, []).last
    found = find_by_id(root_id)
    return if found.nil?

    found.name
  end

  # Returns an array with the names (from root to sub-community) to the given community ID.
  # @param id [<Int>] ID of the community.
  def find_path_name(id)
    ids = find_path(id)
    ids.map { |path_id| find_by_id(path_id).name }
  end

  private

  # Loads community information straight from Dataspace API
  # See DSpace API reference: https://dataspace.princeton.edu/rest/
  def load_from_dataspace
    @tree = []
    communities_url = "#{Rails.configuration.pdc_discovery.dataspace_url}/rest/communities?expand=all"
    Rails.logger.info "Fetching communities information from #{communities_url}"
    response = HTTParty.get(communities_url)
    d_communities = JSON.parse(response.body)
    d_communities.each do |d_community|
      root_community = d_community['parentCommunity'].nil?
      if root_community
        node = DataspaceCommunity.new(d_community, true)
        @tree << node
      end
    end
    @tree
  end

  # Loads community information from a pre-saved file with the information
  def load_from_file(filename)
    @tree = []
    Rails.logger.info "Loading communities information from #{filename}"
    content = File.read(filename)
    d_communities = JSON.parse(content)
    d_communities.each do |d_community|
      root_community = d_community['parentCommunity'].nil?
      if root_community
        node = DataspaceCommunity.new(d_community, false)
        @tree << node
      end
    end
    @tree
  end

  # Returns an array with all the DataspaceCommunity as a flat array.
  # This array is used inernally to perform searches by ID (it's faster to search a flat array
  # than to search a nested structure.)
  def flat_list
    @flat_list ||= begin
      nodes = []
      @tree.each do |node|
        nodes += flat_node(node)
      end
      nodes
    end
  end

  # Returns an array of all the communities and sub-communities for a given community.
  # @param community [<DataspaceCommunity>] a community object.
  def flat_node(community)
    list = [community]
    community.subcommunities.each do |sub|
      list += flat_node(sub)
    end
    list
  end

  # Returns the path (from root to sub-community) to the community as an array of IDs.
  # @param id [<Int>] ID of the community.
  def find_path(id)
    find_path_ids(id, []).reverse
  end

  # Returns the ID of the root community for a given community.
  # @param id [<Int>] ID of the community.
  # @note No testing coverage but not called and private
  def find_root(id)
    find_path_ids(id, []).last
  end

  # Returns the path (community to parent to grandparent) to the community as an array of IDs.
  # @param id [<Int>] ID of the community.
  # @param path [Array<Int>] Array of IDs.
  def find_path_ids(id, path)
    community = find_by_id(id)
    return [] if community.nil?

    path << id
    if community.parent_id.nil?
      path
    else
      find_path_ids(community.parent_id, path)
    end
  end
end
# rubocop:enable Style/Next
