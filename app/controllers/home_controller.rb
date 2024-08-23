# frozen_string_literal: true

class HomeController < ApplicationController
  def about; end

  def features; end

  def policies; end

  def contributors; end

  # Called by the "Contact Us" modal form
  def contact_us
    render json: {} if is_bot?

    # TODO: send email to prds@princeton.edu
    flash.alert = "Thank you for your message."
    redirect_to request.env["HTTP_REFERER"]
  end

  private

    def is_bot?
      # This field is invisible and therefore only bots populate it
      params[:feedback] != ""
    end
end
