# frozen_string_literal: true

# rubocop:disable Style/ClassVars
class VersionFooter
  @@stale = true
  @@git_sha = nil
  @@branch = nil
  @@version = nil

  # Returns a hash with version information coming from Capistrano's log files
  # (../../revisions.log and REVISION). It caches the information so that these
  # files are only read when the version information is stale. When the information
  # is stale the version is not cached so that it is recalculated on the next call.
  def self.info
    reset! if stale?
    { sha: git_sha, branch: branch, version: version, stale: stale? }
  end

  def self.reset!
    # Initalize these values so that they recalculated
    @@git_sha = nil
    @@branch = nil
    @@version = nil
  end

  def self.stale?
    return false if @@stale == false
    # Only check the file when version information is stale
    if File.exist?(revision_file)
      local_sha = File.read(revision_file).chomp.gsub(/\)$/, '')
      @@stale = local_sha != git_sha
    else
      @@stale = true
    end
    @@stale
  end

  def self.git_sha
    @@git_sha ||= begin
      if File.exist?(revisions_logfile)
        `tail -1 #{revisions_logfile}`.chomp.split(" ")[3].gsub(/\)$/, '')
      elsif Rails.env.development? || Rails.env.test?
        `git rev-parse HEAD`.chomp
      else
        "Unknown SHA"
      end
    end
  end

  def self.branch
    @@branch ||= begin
      if File.exist?(revisions_logfile)
        `tail -1 #{revisions_logfile}`.chomp.split(" ")[1]
      elsif Rails.env.development? || Rails.env.test?
        `git rev-parse --abbrev-ref HEAD`.chomp
      else
        "Unknown branch"
      end
    end
  end

  def self.version
    @@version ||= begin
      if File.exist?(revisions_logfile)
        deployed = `tail -1 #{revisions_logfile}`.chomp.split(" ")[7]
        Date.parse(deployed).strftime("%d %B %Y")
      else
        "Not in deployed environment"
      end
    end
  end

  # This file is local to the application
  def self.revision_file
    @@revision_file ||= Rails.root.join("REVISION")
  end

  # Capistrano keeps this file a couple of levels up outside the application
  def self.revisions_logfile
    @@revisions_logfile ||= Rails.root.join("..", "..", "revisions.log")
  end
end
# rubocop:enable RuboCop::Cop::Style::ClassVars
