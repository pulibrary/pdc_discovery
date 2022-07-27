# frozen_string_literal: true
server "pdc-discovery-prod1.princeton.edu", user: "deploy", roles: %w[app db web]
server "pdc-discovery-prod2.princeton.edu", user: "deploy", roles: %w[app db web]
