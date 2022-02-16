# frozen_string_literal: true

# TODO: As our data set grows in size, we might want to get more nuanced about the difference
# between the last time the data changed in the record vs the last time it changed in solr.
# The solr field `timestamp` only records the last time the record was updated in solr.
BlacklightDynamicSitemap::Engine.config.last_modified_field = 'timestamp'
