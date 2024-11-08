# frozen_string_literal: true

# Retrieves version information from Capistrano's files. The general approach is
# to read the version information (branch name, git SHA, and date deployed) out
# of Capistrano's revisions.log file.
#
# The code is a bit more complicated than it should because Capistrano does not
# always update the revision.log file before the application reads this information.
# Therefore there is logic in this class to detect if the version information is
# stale and re-read it until it is up to date. Because re-reading this file is
# an expensive operation we cache the information as soon as we are sure it's
# current.
#
# rubocop:disable Style/ClassVars
class VersionFooter
  DEPLOYMENT_LOGFILE_COL_NUMBER = 7
  REVISIONS_LOG_COL = 3
  DEFAULT_SHA = "Unknown SHA"

  @@stale = true
  @@git_sha = nil
  @@branch = nil
  @@version = nil

  # Returns a hash with version information.
  def self.info
    reset! if stale?
    { sha: git_sha, branch: branch, version: version, stale: stale?, tagged_release: tagged_release? }
  end

  def self.reset!
    # Initalize these values so that they recalculated
    @@git_sha = nil
    @@branch = nil
    @@version = nil

    @@local_sha = nil
    @@revisions = nil

    @@git_sha = nil
    @@revisions_head = nil
    @@revisions_log = nil
  end

  def self.revisions
    return unless File.exist?(revision_file)

    @@revisions ||= File.read(revision_file).chomp
  end

  def self.local_sha
    return unless revisions

    @@local_sha ||= revisions.gsub(/\)$/, '')
  end

  def self.revisions_log
    return unless File.exist?(revisions_logfile)

    content = `tail -1 #{revisions_logfile}`.chomp
    elements = content.split(" ")
    return if elements.length < REVISIONS_LOG_COL

    element = elements[REVISIONS_LOG_COL]
    @@revisions_log ||= element.gsub(/\)$/, '')
  end

  def self.revisions_head
    return unless Rails.env.development? || Rails.env.test?

    @@revisions_head ||= `git rev-parse HEAD`.chomp
  end

  def self.git_sha
    @@git_sha ||= revisions_log || revisions_head || DEFAULT_SHA
  end

  def self.stale?
    return false unless local_sha

    local_sha != git_sha
  end

  def self.tagged_release?
    # e.g. v0.8.0
    branch.match(/^v[\d+\.+]+/) != nil
  end

  def self.branch
    @@branch ||= if File.exist?(revisions_logfile)
                   `tail -1 #{revisions_logfile}`.chomp.split(" ")[1]
                 elsif Rails.env.development? || Rails.env.test?
                   `git rev-parse --abbrev-ref HEAD`.chomp
                 else
                   "Unknown branch"
                 end
  end

  def self.find_version
    return "Not in deployed environment" unless File.exist?(revisions_logfile)

    output = `tail -1 #{revisions_logfile}`
    entries = output.chomp.split(" ")
    return "(Deployment date could not be parsed from: #{output}.)" if entries.length <= DEPLOYMENT_LOGFILE_COL_NUMBER

    deployment_entry = entries[DEPLOYMENT_LOGFILE_COL_NUMBER]
    deployment_date = Date.parse(deployment_entry)
    return "(Deployment date could not be parsed from: #{deployment_entry}.)" if deployment_date.nil?

    formatted = deployment_date.strftime("%d %B %Y")
    formatted
  end

  def self.version
    @@version ||= find_version
  end

  # This file is local to the application.
  # This file only has the git SHA of the version deployed (i.e. no date or branch)
  def self.revision_file
    @@revision_file ||= Rails.root.join("REVISION")
  end

  # Capistrano keeps this file a couple of levels up _outside_ the application.
  # This file includes all the information that we need (git SHA, branch name, date)
  def self.revisions_logfile
    @@revisions_logfile ||= Rails.root.join("..", "..", "revisions.log")
  end

  # These assignment methods are needed to facilitate testing
  def self.revision_file=(x)
    @@revision_file = x
  end

  def self.revisions_logfile=(x)
    @@revisions_logfile = x
  end
end
# rubocop:enable RuboCop::Cop::Style::ClassVars
