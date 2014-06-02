require 'casino_core/processor/api'
require 'casino_core/helper'

# This processor should be used for API calls: POST /cas/v1/tickets
class CASinoCore::Processor::API::LoginCredentialAcceptor < CASinoCore::Processor
  include CASinoCore::Helper::Logger
  include CASinoCore::Helper::ServiceTickets
  include CASinoCore::Helper::Authentication
  include CASinoCore::Helper::TicketGrantingTickets

  # Use this method to process the request. It expects the username in the parameter "username" and the password
  # in "password".
  #
  # The method will call one of the following methods on the listener:
  # * `#user_logged_in_via_api`: First and only argument is a String with the TGT-id
  # * `#invalid_login_credentials_via_api`: No argument
  #
  # @param [Hash] login_data parameters supplied by user (username and password)
  def process(login_data, user_agent = nil)
    @login_data = login_data
    @user_agent = user_agent

    validate_login_data

    unless @authentication_result.nil?
      generate_ticket_granting_ticket
      callback_user_logged_in
    else
      callback_invalid_login_credentials
    end
  end

  def process_after_confirm(login_data, user_agent = nil)
    @username = login_data["username"]
    @user_agent = user_agent
    validate_confirm_data
    unless @authentication_result.nil?
      generate_ticket_granting_ticket
      return [" "]
    else
      return nil
    end
  end

  private
  def validate_login_data
    @authentication_result = validate_login_credentials(@login_data[:username], @login_data[:password])
  end

  def validate_confirm_data
    @authentication_result = validate_confirm_credentials(@username)
  end

  def callback_user_logged_in
    @listener.user_logged_in_via_api @ticket_granting_ticket.ticket
  end

  def generate_ticket_granting_ticket
    @ticket_granting_ticket = acquire_ticket_granting_ticket(@authentication_result, @user_agent)
  end

  def callback_invalid_login_credentials
    @listener.invalid_login_credentials_via_api
  end

end
