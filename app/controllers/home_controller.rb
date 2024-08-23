# frozen_string_literal: true

class HomeController < ApplicationController
  def about; end

  def features; end

  def submit; end

  def policies; end

  def contributors; end

  # Called by the "Contact Us" modal form
  def contact_us
    # TODO: email to prds@princeton.edu
  end
end
