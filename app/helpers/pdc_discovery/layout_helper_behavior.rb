# frozen_string_literal: true

module PdcDiscovery
  module LayoutHelperBehavior
    def main_content_classes
      'col-lg-12'
    end

    def show_content_classes
      "#{main_content_classes} show-document"
    end
  end
end
