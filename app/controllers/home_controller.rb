# frozen_string_literal: true

class HomeController < ApplicationController
  def about; end

  def features; end

  def policies; end

  def contributors; end

  # Called by the "Contact Us" modal form
  def contact_us
    if bot_request?
      # Pretend everything is hunkydory but do nothing
      render json: {}
    else
      # Send the email...
      mail = ContactUsMailer.build_message(contact_info)
      mail.deliver_later(wait: 10.seconds)

      # ...reload the page, and tell the user we've sent their message
      flash.alert = "We have sent your message to our team."
      redirect_to request.env["HTTP_REFERER"] || "/"
    end
  end

  private

  def bot_request?
    # The feedback field is invisible therefore if it's submitted in the request
    # we can safely assume it was a bot.
    params[:feedback].present?
  end

  def contact_info
    {
      name: params[:name],
      email: params[:email],
      message: params[:comment]
    }
  end
end
