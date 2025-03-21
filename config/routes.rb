# frozen_string_literal: true

Rails.application.routes.draw do
  mount HealthMonitor::Engine, at: "/"

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/'

  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new
  root to: 'catalog#index'
  concern :searchable, Blacklight::Routes::Searchable.new

  get 'pppl_reporting_feed' => 'catalog#pppl_reporting_feed', as: :pppl_reporting_feed

  get 'catalog/:id/bibtex' => 'catalog#bibtex', as: :catalog_bibtex
  get 'catalog/:id/file-list' => 'catalog#file_list', as: :catalog_file_list

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end
  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns %i[exportable marc_viewable]
  end
  match "/doi/*doi", via: :get, to: "catalog#resolve_doi", as: :resolve_doi, format: false
  match "/ark/*ark", via: :get, to: "catalog#resolve_ark", as: :resolve_ark, format: false

  resources :bookmarks, only: [:index, :update, :create, :destroy] do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  get 'about' => 'home#about', as: :home_about
  get 'features' => 'home#features', as: :home_features
  get 'policies' => 'home#policies', as: :home_policies
  get 'contributors' => 'home#contributors', as: :home_contributors
  post 'contact_us' => 'home#contact_us', as: :home_contact_us

  # Route all errors to the error controller
  get 'errors/not_found'
  get 'errors/internal_server_error'
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # Anything still unmatched by the end of the routes file should go to the not_found page
  match '*a', to: 'errors#not_found', via: :get

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
