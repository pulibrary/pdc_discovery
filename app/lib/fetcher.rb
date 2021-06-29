# frozen_string_literal: true

require 'faraday'
require 'json'
require 'tmpdir'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

##
# Fetch research data objects from DataSpace
class Fetcher
  REST_LIMIT = 100
  attr_reader :server

  # @param [Hash] opts  options to pass to the client
  # @option opts [String] :server ('https://dataspace.princeton.edu/rest/')
  def initialize(server:)
    @server = server
  end

  # @param id [String] collection id
  # @return [Array<Hash>] metadata hash for each record
  def fetch_collection(id)
    objects = []
    offset = 0
    count = REST_LIMIT
    until count < REST_LIMIT
      url = "#{@server}/collections/#{id}/items?limit=#{REST_LIMIT}&offset=#{offset}&expand=metadata"
      resp = Faraday.get url
      begin
        items = JSON.parse(resp.body)
      # retry if the rest service times out...
      rescue JSON::ParserError => _e
        resp = Faraday.get url
        items = JSON.parse(resp.body)
      end
      objects << items
      count = items.count
      offset += REST_LIMIT
    end
    objects.flatten
  end
end
