# frozen_string_literal: true

class HomeController < ApplicationController
  def about; end

  def features; end

  def policies; end

  def contributors; end

  # Called by the "Contact Us" modal form
  def contact_us
    # byebug
    # TODO: email to prds@princeton.edu
    render json: {}
  end
end
