# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout
  rescue_from ActionView::MissingTemplate, with: :render_not_found

  def render_not_found
    error_view = if Rails.env.production? || Rails.env.staging?
                   '/discovery/errors/not_found'
                 else
                   '/errors/not_found'
                 end

    respond_to do |format|
      format.html { render error_view, status: :not_found }
      format.json { head :not_found }
      format.xml { head :not_found }
      format.rss { head :not_found }
      format.any do
        render "not_found", status: :not_found, formats: [:html]
      end
    end
  end
end
