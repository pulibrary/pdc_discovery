# frozen_string_literal: true

revisions_logfile = Rails.root.join("..", "..", "revisions.log")

GIT_SHA =
  if File.exists?("REVISION")
    File.read("REVISION").chomp.gsub(/\)$/, '')
  elsif Rails.env.development? || Rails.env.test?
    `git rev-parse HEAD`.chomp
  else
    "Unknown SHA"
  end

BRANCH =
  if File.exist?(revisions_logfile)
    revisions_line = `tail -1 #{revisions_logfile}`.chomp
    revisions_sha = revisions_line.split(" ")[3]
    if revisions_sha != GIT_SHA
      "(stale)"
    else
      revisions_line.split(" ")[1]
    end
  elsif Rails.env.development? || Rails.env.test?
    `git rev-parse --abbrev-ref HEAD`.chomp
  else
    "Unknown branch"
  end

LAST_DEPLOYED =
  if File.exist?(revisions_logfile)
    deployed_dir = Dir.getwd.split("/").last
    if deployed_dir.start_with?(/\d\d\d\d\d\d\d\d/)
      Date.parse(deployed_dir).strftime("%d %B %Y")
    else
      "N/A"
    end
  else
    "Not in deployed environment"
  end
