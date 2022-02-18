require "httparty"
require "json"
# DSpace API reference: https://dataspace.princeton.edu/rest/
#
# Notice that the top_communities_url returns collections for a top community but NOT the subcommunities
# top_communities_url does not return plasma?????
# top_communities_url = "https://dataspace.princeton.edu/rest/communities/top-communities?expand=all"

class DataspaceCommunities
  attr_reader :tree

  def initialize()
    @tree = []
    @flat_list = nil
  end

  def load_from_dataspace
    @tree = []
    communities_url = "https://dataspace.princeton.edu/rest/communities?expand=all"
    response = HTTParty.get(communities_url)
    d_communities = JSON.parse(response.body)
    d_communities.each do |d_community|
      next if d_community["parentCommunity"] != nil
      node = DataspaceCommunity.new(d_community, true)
      @tree << node
    end
    @tree
  end

  def load_from_file(filename)
    @tree = []
    content = File.read(filename)
    d_communities = JSON.parse(content)
    d_communities.each do |d_community|
      next if d_community["parentCommunity"] != nil
      node = DataspaceCommunity.new(d_community, false)
      @tree << node
    end
    @tree
  end

  # All communities as a flat array
  def flat_list
    @flat_list ||= begin
      nodes = []
      @tree.each do |node|
        nodes += flat_node(node)
      end
      nodes
    end
  end

  def find_by_id(id)
    flat_list.find { |community| community.id == id }
  end

  # def find_by_handle(handle)
  #   flat_list.find { |community| community.handle == handle }
  # end

  # Returns the path (from root to sub-community) to the community as an array of IDs.
  def find_path(id)
    find_path_ids(id, []).reverse
  end

  # Returns the path (from root to sub-community) to the community as an array of names.
  def find_path_name(id)
    ids = find_path(id)
    ids.map { |id| find_by_id(id).name }
  end

  def find_root(id)
    find_path_ids(id, []).reverse.first
  end

  def find_root_name(id)
    root_id = find_path_ids(id, []).reverse.first
    find_by_id(root_id).name
  end

  def find_path_ids(id, path)
    node = find_by_id(id)
    return nil if node.nil?
    path << id
    if node.parent_id == nil
      path
    else
      find_path(node.parent_id, path)
    end
  end

  def flat_node(node)
    list = [node]
    node.subcommunities.each do |sub|
      list += flat_node(sub)
    end
    list
  end

  def self.load_from_dataspace
    communities = DataspaceCommunities.new
    communities.load_from_dataspace
    communities
  end

  def self.load_from_file(filename)
    communities = DataspaceCommunities.new
    communities.load_from_file(filename)
    communities
  end
end