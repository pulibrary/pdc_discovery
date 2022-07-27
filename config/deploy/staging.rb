# frozen_string_literal: true
server "pdc-discovery-staging1.princeton.edu", user: "deploy", roles: %w[app db web]
server "pdc-discovery-staging2.princeton.edu", user: "deploy", roles: %w[app db web]
