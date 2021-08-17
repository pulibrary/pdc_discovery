# frozen_string_literal: true
##
# Tag a release of a this application, E.g., cam release blacklight
# This will:
# 1. Auto-generate release notes for the new version
# 2. Determine whether there are any features or breaking changes, and increment the version number accordingly
# 3. Tag the release in github with the new version number and the release notes
desc "tag a release of this application, e.g., rake release"
task tag: :environment do
  puts "You must set CHANGELOG_GITHUB_TOKEN. See https://github.com/github-changelog-generator/github-changelog-generator#github-token" unless ENV['CHANGELOG_GITHUB_TOKEN']
  # taggable_apps = TaggableApp.known_apps
  # unless taggable_apps.include? app
  #   puts "I don't know how to release #{app}."
  #   puts "I only know how to release these apps: #{taggable_apps}"
  #   exit(1)
  # end
  taggable_app = TaggableApp.new('pdc_discovery')
  unless taggable_app.release_needed?
    puts "No new release needed for #{app}"
    exit(0)
  end
  taggable_app.release
  puts "Released #{app} #{taggable_app.new_version_number}"
end
