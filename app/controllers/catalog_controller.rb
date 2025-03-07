# frozen_string_literal: true

class CatalogController < ApplicationController
  include Blacklight::Catalog
  include BlacklightRangeLimit::ControllerOverride

  include Blacklight::Marc::Catalog

  around_action :retry_on_exception

  rescue_from Blacklight::Exceptions::RecordNotFound do
    error_page = Rails.env.production? || Rails.env.staging? ? '/discovery/errors/not_found' : '/errors/not_found'
    redirect_to error_page
  end

  def retry_on_exception
    yield
  rescue Blacklight::Exceptions::ECONNREFUSED, RSolr::Error::ConnectionRefused
    # If the Solr service is available, retry the HTTP request
    if search_service.repository.ping
      retry
    else
      error_page = Rails.env.production? || Rails.env.staging? ? '/discovery/errors/network_error' : '/errors/network_error'
      redirect_to error_page
    end
  end

  configure_blacklight do |config|
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    config.raw_endpoint.enabled = true

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      rows: 10
    }

    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'select'
    # config.document_solr_path = 'get'

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]

    # solr field configuration for search results/index views
    config.index.title_field = 'title_tesim'
    # config.index.display_type_field = 'format'
    # config.index.thumbnail_field = 'thumbnail_path_ss'

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    # config.show.display_type_field = 'format'
    # config.show.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    # config.add_facet_field 'example_pivot_field', label: 'Pivot Field', pivot: %w[format language_ssim], collapsing: true

    # config.add_facet_field 'example_query_facet_field', label: 'Publish Date', query: {
    #   years_5: { label: 'within 5 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 5} TO *]" },
    #   years_10: { label: 'within 10 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 10} TO *]" },
    #   years_25: { label: 'within 25 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 25} TO *]" }
    # }

    # TODO: When we upgrade to Blacklight 8
    #  We can remove the `component: Blacklight::FacetFieldListComponent` from the `add_facet_field` lines
    #  It is only present to remove a deprecation warning in Blacklight 7 that ironically is not needed for Blacklight 8
    #
    config.add_facet_field 'domain_ssim', label: 'Domain', limit: 5, component: Blacklight::FacetFieldListComponent
    config.add_facet_field 'communities_ssim', label: 'Community', limit: 5, component: Blacklight::FacetFieldListComponent
    config.add_facet_field 'subcommunities_ssim', label: 'Subcommunity', limit: 5, component: Blacklight::FacetFieldListComponent

    config.add_facet_field 'collection_tag_ssim', label: 'Collection Tags', limit: 5, component: Blacklight::FacetFieldListComponent
    config.add_facet_field 'authors_affiliation_ssim', label: 'Affiliation', limit: 5, component: Blacklight::FacetFieldListComponent

    config.add_facet_field 'genre_ssim', label: 'Type', limit: 5, component: Blacklight::FacetFieldListComponent
    config.add_facet_field 'year_available_itsi', label: 'Year Published', range: true

    # Notice that is facet is not shown. Yet facet searches by this field do work
    # and we use them when users click on the "Keywords" links in the Show page.
    config.add_facet_field 'subject_all_ssim', label: 'Keywords', show: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display

    # Notice that for the author field we key of the `author_tesim` field but in reality
    # we render a different value (see the helper). We use `author_tesim` in here because
    # that is a common field between all our records, the ones coming from DataSpace
    # and the ones coming from PDC Describe.
    config.add_index_field 'author_tesim', label: 'Author(s)', helper_method: :authors_search_results_helper

    config.add_index_field 'format', label: 'Format'
    config.add_index_field 'abstract_tsim', label: 'Abstract'
    config.add_index_field 'published_ssim', label: 'Published'
    config.add_index_field 'published_vern_ssim', label: 'Published'
    config.add_index_field 'genre_ssim', label: 'Type'
    config.add_index_field 'issue_date_ssim', label: 'Issue Date'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'author_tesim', label: 'Author'
    config.add_show_field 'format', label: 'Format'
    config.add_show_field 'url_fulltext_ssim', label: 'URL'
    config.add_show_field 'url_suppl_ssim', label: 'More Information'
    config.add_show_field 'language_ssim', label: 'Language'
    config.add_show_field 'published_ssim', label: 'Published'
    config.add_show_field 'published_vern_ssim', label: 'Published'
    config.add_show_field 'lc_callnum_ssim', label: 'Call number'
    config.add_show_field 'isbn_ssim', label: 'ISBN'
    config.add_show_field 'handle_ssim', label: 'Handle'

    config.add_show_field 'abstract_tsim', label: 'Abstract'
    config.add_show_field 'contributor_tsim', label: 'Author'
    config.add_show_field 'description_tsim', label: 'Description'
    config.add_show_field 'issue_date_ssim', label: 'Issued Date'
    config.add_show_field 'methods_tsim', label: 'Methods'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: 'All Fields'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
        'spellcheck.dictionary': 'title',
        qf: '${title_qf}',
        pf: '${title_pf}'
      }
    end

    config.add_search_field('author') do |field|
      field.solr_parameters = {
        'spellcheck.dictionary': 'author',
        qf: '${author_qf}',
        pf: '${author_pf}'
      }
    end

    config.add_search_field('orcid') do |field|
      field.label = "ORCID"
      field.solr_parameters = {
        qf: 'authors_orcid_ssim',
        pf: 'authors_orcid_ssim'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.qt = 'search'
      field.solr_parameters = {
        'spellcheck.dictionary': 'subject',
        qf: '${subject_qf}',
        pf: '${subject_pf}'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the Solr field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case). Add the sort: option to configure a
    # custom Blacklight url parameter value separate from the Solr sort fields.
    config.add_sort_field 'relevance', sort: 'score desc, issue_date_strict_ssi desc, title_si asc', label: 'relevance'
    config.add_sort_field 'year', sort: 'issue_date_strict_ssi desc, title_si asc', label: 'year'
    config.add_sort_field 'author', sort: 'author_si asc, title_si asc', label: 'author'
    config.add_sort_field 'title', sort: 'title_si asc, issue_date_strict_ssi desc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # # Configuration for autocomplete suggester
    # config.autocomplete_enabled = true
    # config.autocomplete_path = 'suggest'
    # # if the name of the solr.SuggestComponent provided in your solrconfig.xml is not the
    # # default 'mySuggester', uncomment and provide it below
    # # config.autocomplete_suggester = 'mySuggester'
    config.search_state_fields = config.search_state_fields + [
      :doi, :ark, :id,
      :a # this is in the search parameters becuase the search bar is shown on the error page
    ]

    # Sets up Blacklight crawler detection
    config.crawler_detector = lambda { |request|
      return true if request.env['HTTP_USER_AGENT'].blank?
      request.bot?
    }
  end

  def show
    @render_links = !agent_is_crawler?
    super
    if params["format"] == "json"
      render json: DocumentExport.new(@document)
    end
  end

  # This endpoint is used to feed the AJAX call on the Show page for the file list and
  # therefore the return JSON must be something that DataTables can use.
  def file_list
    document = solr_find(params["id"])
    file_list = { data: document.files }

    render json: file_list.to_json
  end

  # Returns the raw BibTex citation information
  def bibtex
    _unused, @document = search_service.fetch(params[:id])
    citation = @document.cite("BibTeX")
    send_data citation, filename: "#{@document.bibtex_id}.bibtex", type: 'text/plain', disposition: 'attachment'
  end

  def resolve_doi
    raise Blacklight::Exceptions::RecordNotFound unless params.key?(:doi)

    doi_query = params[:doi]
    query = { q: "uri_ssim:*\"#{doi_query}\"" }

    solr_response = search_service.repository.search(**query)
    documents = solr_response.documents

    raise Blacklight::Exceptions::RecordNotFound if documents.empty?
    preferred = documents.select { |d| d.data_source == 'pdc_discovery' }
    document = if preferred.empty?
                 documents.first
               else
                 preferred.first
               end

    redirect_to(solr_document_path(id: document.id))
  end

  def resolve_ark
    raise Blacklight::Exceptions::RecordNotFound unless params.key?(:ark)

    ark = params[:ark]
    ark_query = "uri_ssim:*\"#{ark}\""
    query = { q: ark_query }

    solr_response = search_service.repository.search(**query)
    documents = solr_response.documents

    raise Blacklight::Exceptions::RecordNotFound if documents.empty?
    document = documents.first

    redirect_to(solr_document_path(id: document.id))
  end

  # Create an endpoint for PPPL / OSTI harvesting that provides full datacite records
  def pppl_reporting_feed
    # Limit to items from PPPL
    lucene_queries = ['data_source_ssi:pdc_describe', 'group_code_ssi:"PPPL"']
    lucene_expr = lucene_queries.join(" ")
    page = params["page"] || "1"
    per_page = params["per_page"] || "10"
    start = per_page.to_i * (page.to_i - 1)

    query_sort = 'internal_id_lsi desc'
    query_fl = 'pdc_describe_json_ss'
    query_format = 'json'
    query = {
      q: lucene_expr,
      fl: query_fl,
      format: query_format,
      sort: query_sort,
      rows: per_page,
      start: start
    }

    solr_response = search_service.repository.search(**query)

    @documents = solr_response.documents
    respond_to do |format|
      format.json { render json: @documents }
    end
  end

  private

  def solr_find(id)
    solr_url = Blacklight.default_configuration.connection_config[:url]
    solr = RSolr.connect(url: solr_url)
    solr_params = { q: "id:#{id}", fl: '*' }
    response = solr.get('select', params: solr_params)
    solr_doc = response["response"]["docs"][0]
    SolrDocument.new(solr_doc)
  end
end
