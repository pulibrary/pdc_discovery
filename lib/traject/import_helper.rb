# frozen_string_literal: true

# rubocop:disable Style/ClassVars (OK here since we are not inheriting this class)
# https://rubydoc.info/gems/rubocop/RuboCop/Cop/Style/ClassVars
class ImportHelper
  @@solr_leader_url = nil
  @@solr_writer_url = nil

  def self.uri_with_prefix(prefix, value)
    return nil if value.blank?
    "#{prefix}/#{value}"
  end

  def self.solr_leader_url
    @@solr_leader_url ||= solr_leader_for_uri(Blacklight.default_index.connection.uri)
  end

  def self.solr_writer_url
    solr_config_name = "pdc-discovery-staging"
    @@solr_writer_url ||= solr_writer_for_uri(Blacklight.default_index.connection.uri, solr_config_name)
  end

  def self.solr_writer_for_uri(solr_uri, solr_config_name)
    byebug
    alternate_collection = alternate_collection_for_alias(solr_uri)
    if collection_exist?(solr_uri, alternate_collection)
      alternate_collection
    else
      create_collection(solr_uri, alternate_collection, solr_config_name)
    end
  end

  # solr_uri = http://xxx/solr/pdc-discovery-staging
  def self.current_collection_for_alias(solr_uri)
    alias_name = solr_uri.path.split("/").last
    alias_list_query = URI::HTTP.build(
      schema: solr_uri.scheme,
      host: solr_uri.host,
      port: solr_uri.port,
      path: "/solr/admin/collections",
      query: "action=LISTALIASES"
    )
    response = HTTParty.get(alias_list_query.to_s)
    # The response will indicate the actual collection the alias points to.
    collection_name = response.parsed_response.dig("aliases", alias_name) if response.code == 200
    collection_name || alias_name
  end

  # solr_uri = http://xxx/solr/pdc-discovery-staging
  # returns pdc-discovery-staging-N (or pdc-discovery-staging)
  def self.alternate_collection_for_alias(solr_uri)
    solr_collection = current_collection_for_alias(solr_uri)
    if solr_collection.end_with?("-1")
      solr_collection.gsub("-1", "-2")
    elsif solr_collection.end_with?("-2")
      solr_collection.gsub("-2", "-1")
    else
      solr_collection
    end
  end

  def self.collection_exist?(solr_uri, collection_name)
    collection_list_query = URI::HTTP.build(
      schema: solr_uri.scheme,
      host: solr_uri.host,
      port: solr_uri.port,
      path: "/solr/admin/collections",
      query: "action=LIST"
    )
    response = HTTParty.get(collection_list_query.to_s)
    collections = if response.code == 200
      response.parsed_response.dig("collections") || []
    else
      []
    end
    collections.any?(collection_name)
  end

  def self.create_collection(solr_uri, collection_name, config_name)
    create_query = URI::HTTP.build(
      schema: solr_uri.scheme,
      host: solr_uri.host,
      port: solr_uri.port,
      path: "/solr/admin/collections",
      query: "action=CREATE&name=#{collection_name}&collection.configName=#{config_name}&numShards=1&replicationFactor=2"
    )
    response = HTTParty.get(create_query.to_s)
    if response.parsed_response.has_key?("success")
      collection_name
    else
      nil
    end
  end

  def self.update_solr_alias(solr_uri, collection_name)
    alias_name = solr_uri.path.split("/").last
    create_query = URI::HTTP.build(
      schema: solr_uri.scheme,
      host: solr_uri.host,
      port: solr_uri.port,
      path: "/solr/admin/collections",
      query: "action=CREATEALIAS&name=#{alias_name}&collections=#{collection_name}"
    )
    response = HTTParty.get(create_query.to_s)
    byebug
    true
  end


  # Finds the Solr collection that a Solr URI maps to.
  #
  # If the Solr URI points to an alias it returns the collection that the alias is mapped to,
  # otherwise it assumes the URI already points to a collection.
  def self.solr_collection_for_uri(solr_uri)
    collection = solr_uri.path.split("/").last
    alias_list_query = URI::HTTP.build(
      schema: solr_uri.scheme,
      host: solr_uri.host,
      port: solr_uri.port,
      path: "/solr/admin/collections",
      query: "action=LISTALIASES"
    )
    response = HTTParty.get(alias_list_query.to_s)
    aliased_collection = (response.parsed_response.dig("aliases", collection) if response.code == 200)
    aliased_collection || collection
  end

  # Returns the leader URL that a given Solr URI is mapped to.
  def self.solr_leader_for_uri(solr_uri)
    collection_name = solr_collection_for_uri(solr_uri)
    collection_admin_query = URI::HTTP.build(
      schema: solr_uri.scheme,
      host: solr_uri.host,
      port: solr_uri.port,
      path: "/solr/admin/collections",
      query: "action=COLSTATUS&collection=#{collection_name}"
    )

    response = HTTParty.get(collection_admin_query.to_s)
    if response.code != 200
      # We are not running in a Solr cloud environment, use the Solr's core URL.
      solr_uri.to_s
    else
      # Pick the URL of the leader indicated in the response
      shards = response.parsed_response.dig(collection_name, "shards")
      raise "Could not determine Solr leader for #{solr_uri}" if shards.nil?
      leader_base_url = shards.dig(shards.keys.first, "leader", "base_url")
      URI.join(leader_base_url, "/solr/#{collection_name}/").to_s
    end
  end

  def self.doi_uri(value)
    uri_with_prefix("https://doi.org", value)
  end

  def self.ark_uri(value)
    uri_with_prefix("http://arks.princeton.edu", value)
  end

  # Returns true if a record already exists in Solr for the given URIs
  # and that record was imported from PDC Describe.
  def self.pdc_describe_match?(uris)
    ark_uri = uris.find { |uri| uri.text.start_with?("http://arks.princeton.edu/ark:/") }&.text
    return true if pdc_describe_match_by_uri?(ark_uri)

    doi_uri = uris.find { |uri| uri.text.start_with?("https://doi.org/10.34770/") }&.text
    return true if pdc_describe_match_by_uri?(doi_uri)

    false
  end

  # Returns true if a record already exists in Solr for the given URI
  # provided and that record was imported from PDC Describe.
  #
  # Notice that we always query the Solr leader in this case, because in a replicated Solr
  # configuration the most up to date information is always in the leader (e.g. the replicas
  # report that the record still exists for a few minutes after being deleted.)
  def self.pdc_describe_match_by_uri?(uri)
    return false if uri.nil?
    solr_query = "#{solr_leader_url}select?q=data_source_ssi:pdc_describe+AND+uri_ssim:\"#{uri}\""
    response = HTTParty.get(solr_query)
    response.parsed_response["response"]["numFound"] != 0
  end
end
# rubocop:enable Style/ClassVars
