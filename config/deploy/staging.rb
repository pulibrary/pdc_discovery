# frozen_string_literal: true
server "pdc-discovery-staging1.lib.princeton.edu", user: "deploy", roles: %w[app db web reindex]
server "pdc-discovery-staging2.lib.princeton.edu", user: "deploy", roles: %w[app db web]
