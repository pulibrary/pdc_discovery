# frozen_string_literal: true

require 'faraday'
require 'json'
require 'tmpdir'
require 'openssl'

##
# Fetch research data objects from DataSpace
class Fetcher
  attr_reader :server, :community

  # @param [Hash] opts  options to pass to the client
  # @option opts [String] :server ('https://dataspace.princeton.edu/rest/')
  # @option opts [String] :community ('267')
  def initialize(server:, community:)
    @server = server
    @community = community
  end
end
