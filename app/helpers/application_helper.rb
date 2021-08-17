# frozen_string_literal: true

module ApplicationHelper
  def render_document_heading; end

  def debug
    blacklight_config.view_config(:show, action_name: action_name).document_presenter_class
  end
end
