# frozen_string_literal: true
class ContactUsMailer < ApplicationMailer
  def build_message(contact_info)
    @email_to = Rails.configuration.pdc_discovery.contact_email
    @name = contact_info[:name]
    @email_from = contact_info[:email]
    @message = contact_info[:message]
    @subject = "PDC Discovery message from #{@name}"
    mail(to: @email_to, subject: @subject)
  end
end
