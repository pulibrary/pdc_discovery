# frozen_string_literal: true
##
# Tag a release of a microservice, E.g., cam tag blacklight
# This will:
# 1. Use github_changelog_generator to generate release notes
# 2. Determine whether any of them are features or breaking changes, and increment the version number accordingly
# 3. If a release is needed, tag the release in github with the new version number and the release notes
require 'github_changelog_generator'
require 'octokit'
require 'set'

class TaggableApp
  attr_reader :github_user, :github_project
  BREAKING_PREFIX = "Backwards incompatible changes:"
  ENHANCEMENT_PREFIX = "New Features:"
  BUG_PREFIX = "Fixed Bugs:"
  MERGE_PREFIX = "Technical Enhancements:"
  SECURITY_PREFIX = "Security fixes:"
  RELEASE_PLACEHOLDER = "v9999"

  ##
  # Make an instance that's configured for a specific application
  def initialize(app)
    raise "Unknown app name: #{app}" unless TaggableApp.known_apps.include?(app)
    raise "CHANGELOG_GITHUB_TOKEN not found" if ENV['CHANGELOG_GITHUB_TOKEN'].blank?
    @app = app
    @config = TaggableApp.config[app.to_sym]
    @github_user = @config[:github_user]
    @github_project = @config[:github_project]
    @client = ::Octokit::Client.new(access_token: ENV['CHANGELOG_GITHUB_TOKEN'])
  end

  ##
  # Setup for generating release notes.
  # Set future release to "v9999" so we can easily replace it with our real
  # release tag
  def generator
    return @generator if @generator
    options = ::GitHubChangelogGenerator::Parser.default_options
    options[:user] = @github_user
    options[:project] = @github_project
    options[:since_tag] = last_version_number
    options[:future_release] = RELEASE_PLACEHOLDER
    options[:token] = ENV['CHANGELOG_GITHUB_TOKEN']
    options[:enhancement_labels] = ["Feature", "Features", "feature", "features", "enhancement", "Enhancement"]
    options[:bug_labels] = ["Bug", "Bugs", "bug", "bugs"]
    options[:breaking_prefix] = "**#{BREAKING_PREFIX}**"
    options[:enhancement_prefix] = "**#{ENHANCEMENT_PREFIX}**"
    options[:bug_prefix] = "**#{BUG_PREFIX}**"
    options[:merge_prefix] = "**#{MERGE_PREFIX}**"
    options[:security_labels] = ["dependencies", "security"]
    options[:security_prefix] = "**#{SECURITY_PREFIX}**"
    @generator = GitHubChangelogGenerator::Generator.new options
    @generator
  end

  ##
  # Generate release notes for all PRs merged since the last release
  def generate_release_notes
    generator.compound_changelog
  end

  ##
  # The most recent release
  def last_release
    @last_release ||= @client.releases("#{@github_user}/#{@github_project}")[0]
  end

  ##
  # Do we need a new release?
  # If the release notes do not match any of our headings, then we must
  # not need a new release
  def release_needed?
    return true if major_release
    return true if feature_release
    return true if patch_release
    false
  end

  ##
  # The name of the most recent release
  def last_version_number
    last_release[:name]
  end

  def major_release
    !!release_notes.match(/#{BREAKING_PREFIX}/)
  end

  def feature_release
    !!release_notes.match(/#{ENHANCEMENT_PREFIX}/)
  end

  def patch_release
    !!(
        release_notes.match(/#{BUG_PREFIX}/) ||
        release_notes.match(/#{MERGE_PREFIX}/) ||
        release_notes.match(/#{SECURITY_PREFIX}/)
      )
  end

  ##
  # The name of the upcoming release
  def new_version_number
    @new_version_number ||= calculate_new_version_number
  end

  ##
  # Fetch all the merged PRs since the last release, and determine whether any of
  # them had a "Feature" label. If so, increment the minor part of the version number.
  # If not, increment the patch part of the version number.
  def calculate_new_version_number
    major, minor, patch = last_version_number.split(".")

    if major_release
      major = major.delete('v').to_i + 1
      major = "v#{major}"
      minor = 0
      patch = 0
    elsif feature_release
      minor = minor.to_i + 1
      patch = 0
    else
      patch = patch.to_i + 1
    end
    "#{major}.#{minor}.#{patch}"
  end

  def release_notes
    @release_notes ||= generate_release_notes
  end

  ##
  # In order to release one of our microservices, we need to know the github_user and github_project
  # TODO: Move this to somewhere more obvious in case we want to change this config
  def self.config
    {
      pdc_discovery:
        {
          github_user: 'pulibrary',
          github_project: 'pdc_discovery'
        }
    }
  end

  ##
  # List the applications we know how to tag
  def self.known_apps
    config.keys.map(&:to_s)
  end

  ##
  # Actually tag a release. Pass the release notes and the new version number.
  def release
    final_release_notes = release_notes.gsub(RELEASE_PLACEHOLDER, new_version_number)
    release_options = { name: new_version_number, body: final_release_notes }
    @client.create_release("#{@github_user}/#{@github_project}", new_version_number, release_options)
  end

  def version_file
    File.join(__dir__, 'version.rb')
  end

  def make_version_tempfile
    tfile = Tempfile.new(File.basename(version_file))
    tfile.write version_file_contents
    tfile.close
    tfile
  end

  ##
  # Re-write the version file to update it to the latest version number
  def version_file_contents
    "# frozen_string_literal: true\nVERSION = '#{new_version_number.delete('v')}'\nend\n"
  end
end
