# frozen_string_literal: true

require 'thor'

##
# Command line interface for processing theses
class Cli < Thor
  method_option :collection_handle, aliases: '-c', type: :string, desc: 'The handle identifier of the DataSpace collection to be indexed'

  desc 'index', 'Index a DataSpace collection for discovery in the Princeton Data Commons'
  def index
    if all_required_options_present?
      puts "Indexing for Princeton Data Commons"
      output_options
      # Indexer.index(options)
    else
      output_help_message
    end
  end

  def self.exit_on_failure?
    true
  end

  no_commands do
    def output_help_message
      puts 'Type thor help cli:index for a list of all options'
    end

    def output_options
      puts "Processing handle #{options[:collection_handle]}."
    end

    def all_required_options_present?
      true if options[:collection_handle]
    end
  end
end
