# frozen_string_literal: true

class SolrCloudHelper
  def self.alias_uri
    Blacklight.default_index.connection.uri
  end

  def self.alias_url
    Blacklight.default_index.connection.uri.to_s
  end

  def self.config_set
    Blacklight.default_index.connection.options[:solr_config_set]
  end

  def self.collection_writer_commit!
    commit_url = "#{collection_writer_url}/update?commit=true"
    HTTParty.get(commit_url)
  end

  # Returns the Solr collection that we should use for quering data
  def self.collection_reader_url
    collection = current_collection_for_alias(alias_uri)
    build_solr_url_for_collection(alias_uri, collection)
  end

  # Returns the Solr collection that we should write to
  # (creates it if does not exist)
  def self.collection_writer_url
    collection_writer_for_alias(alias_uri, false)
  end

  # Returns the Solr collection that we should write to
  # (creates it if does not exists, deletes & recreates it if already exists)
  def self.create_collection_writer
    collection_writer_for_alias(alias_uri, true)
  end

  # For a given Solr alias, returns a URL that is suitable for writing new data without affecting
  # the existing Solr index. It does this by creating a new alternate Solr collection to write data,
  # instead of overwriting the data on the collection used by the provided solr_alias_uri.
  #
  # The code is hardcoded to toggle between collections "xxx-1 and "xxx-2".
  #
  # For example, if the provided solr_alias_uri is "http://server/solr/pdc-discovery-staging"
  # and this alias is configured in Solr to point to collection "http://server/solr/pdc-discovery-staging-1"
  # the returned writer URL will be "http://server/solr/pdc-discovery-staging-2".
  #
  # If the alias was configured to point to collection "http://server/solr/pdc-discovery-staging-2"
  # then the returned writer URL will be "http://server/solr/pdc-discovery-staging-1".
  def self.collection_writer_for_alias(solr_alias_uri, recreate)
    if config_set.nil?
      # We are not running in a Solr cloud environment - nothing to do.
      return solr_alias_uri.to_s
    end

    alternate_collection = alternate_collection_for_alias(solr_alias_uri)
    if collection_exist?(solr_alias_uri, alternate_collection)
      if recreate
        # Re-create it
        delete_collection!(solr_alias_uri, alternate_collection)
        create_collection(solr_alias_uri, alternate_collection)
      end
    else
      # Create it
      create_collection(solr_alias_uri, alternate_collection)
    end

    build_solr_url_for_collection(solr_alias_uri, alternate_collection)
  end

  # Returns the Solr URL based on the provided `solr_alias_uri`` but updated to use
  # the indicated `collection` instead of pointing to the alias.
  def self.build_solr_url_for_collection(solr_alias_uri, collection)
    build_uri(base_uri: solr_alias_uri, path: "/solr/#{collection}").to_s
  end

  def self.current_collection_for_alias(solr_alias_uri)
    alias_name = solr_alias_uri.path.split("/").last
    alias_list_query = build_uri(base_uri: solr_alias_uri, path: "/solr/admin/collections", query: "action=LISTALIASES")
    response = HTTParty.get(alias_list_query.to_s)
    # The response will indicate the actual collection the alias points to.
    collection_name = response.parsed_response.dig("aliases", alias_name) if response.code == 200
    collection_name || alias_name
  end

  def self.alternate_collection_for_alias(solr_alias_uri)
    solr_collection = current_collection_for_alias(solr_alias_uri)
    if solr_collection.end_with?("-1")
      solr_collection.gsub("-1", "-2")
    elsif solr_collection.end_with?("-2")
      solr_collection.gsub("-2", "-1")
    else
      solr_collection
    end
  end

  def self.collection_exist?(solr_alias_uri, collection_name)
    collection_list_query = build_uri(base_uri: solr_alias_uri, path: "/solr/admin/collections", query: "action=LIST")
    response = HTTParty.get(collection_list_query.to_s)
    collections = if response.code == 200
                    response.parsed_response.dig("collections") || []
                  else
                    []
                  end
    collections.any?(collection_name)
  end

  def self.create_collection(solr_alias_uri, collection_name)
    create_query = build_uri(
      base_uri: solr_alias_uri,
      path: "/solr/admin/collections",
      query: "action=CREATE&name=#{collection_name}&collection.configName=#{config_set}&numShards=1&replicationFactor=3"
    )
    response = HTTParty.get(create_query.to_s)
    return unless response.code == 200 && response.parsed_response.key?("success")
    collection_name
  end

  def self.delete_collection!(solr_alias_uri, collection_name)
    create_query = build_uri(
      base_uri: solr_alias_uri,
      path: "/solr/admin/collections",
      query: "action=DELETE&name=#{collection_name}"
    )
    response = HTTParty.get(create_query.to_s)
    response.code == 200
  end

  # Set the solr_alias to point to the current writer collection
  def self.update_solr_alias!
    writer_collection = collection_writer_url.split("/").last

    alias_name = alias_uri.path.split("/").last
    if alias_name == writer_collection
      # Nothing to do
      # (we are probably using standalone Solr in development)
      return true
    end

    create_query = build_uri(
      base_uri: alias_uri,
      path: "/solr/admin/collections",
      query: "action=CREATEALIAS&name=#{alias_name}&collections=#{writer_collection}"
    )
    response = HTTParty.get(create_query.to_s)
    response.code == 200
  end

  # Build a URI using another URI as the base.
  def self.build_uri(base_uri:, path:, query: nil)
    URI::HTTP.build(
      schema: base_uri.scheme,
      userinfo: base_uri.userinfo,
      host: base_uri.host,
      port: base_uri.port,
      path: path,
      query: query
    )
  end
end
