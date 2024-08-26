# frozen_string_literal: true

class HomeController < ApplicationController
  def about; end

  def features; end

  def policies; end

  def contributors; end

  # Called by the "Contact Us" modal form
  def contact_us
    render json: {} if bot_request?

    # TODO: send email to prds@princeton.edu
    flash.alert = "We have sent your message to our team."
    redirect_to request.env["HTTP_REFERER"]
  end

  private

  def bot_request?
    # This field is invisible therefore if it's submitted in the request
    # we can safely assume it was a bot.
    params[:feedback] != ""
  end
end
