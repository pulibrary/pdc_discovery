# frozen_string_literal: true

require "httparty"
require "json"

# rubocop:disable Rails/Delegate
class DataspaceCommunity
  attr_accessor :id, :name, :handle, :collections, :subcommunities, :parent_id

  # d_community is a hash with DSpace community information
  def initialize(d_community, fetch_from_dataspace = false)
    @id = d_community['id']
    @name = d_community['name']
    @handle = d_community['handle']
    @parent_id = fetch_from_dataspace ? d_community.dig('parentCommunity', 'id') : d_community['parent_id']

    @collections = []
    d_community['collections'].each do |d_collection|
      @collections << { id: d_collection['id'], name: d_collection['name'] }
    end

    @subcommunities = []
    d_community['subcommunities'].each do |d_sub_community|
      if fetch_from_dataspace
        # Fetch data from dataspace since the subcommunity information does not come on the community response
        # by default.
        sub_community_url = "#{Rails.configuration.pdc_discovery.dataspace_url}/rest/communities/#{d_sub_community['id']}?expand=all"
        response = HTTParty.get(sub_community_url)
        d_sub_community = JSON.parse(response.body)
        @subcommunities << DataspaceCommunity.new(d_sub_community, true)
      else
        # Use the data that we got as-is.
        # This is used when building the nodes from cache where we have all the information already available.
        @subcommunities << DataspaceCommunity.new(d_sub_community, false)
      end
    end
  end

  # @note Not covered in testing but not called
  def to_hash
    hash = {
      id: @id,
      name: @name,
      handle: @handle,
      collections: @collections,
      subcommunities: @subcommunities,
      parent_id: @parent_id
    }
    hash
  end

  # @note Not covered in testing but not called
  def to_json(opts)
    to_hash.to_json(opts)
  end
end
# rubocop:enable Rails/Delegate
