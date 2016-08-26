require 'login_not_found'

# The controller that implements the engine's endpoints.
#
# @!visibility private
class Oauth2Controller < ApplicationController

  PASSWORD_PROVIDER_NAME = 'password'.freeze
  FACEBOOK_PROVIDER_NAME = 'facebook'.freeze
  GOOGLE_PROVIDER_NAME = 'google'.freeze
  EDX_PROVIDER_NAME = 'edx'.freeze
  DEFAULT_CLIENT_NAME = 'unspecified'.freeze

  force_ssl if: -> { RailsApiAuth.force_ssl }

  # rubocop:disable MethodLength
  def create
    client = params[:accessing_application]
    client ||= DEFAULT_CLIENT_NAME

    case params[:grant_type]
    when 'password'
      authenticate_with_credentials(params[:username], params[:password], PASSWORD_PROVIDER_NAME, client)
    when 'facebook_auth_code'
      authenticate_with_facebook(params[:auth_code], client)
    when 'google_auth_code'
      authenticate_with_google(params[:auth_code], client)
    when 'edx_auth_code'
      authenticate_with_edx(params[:username], params[:auth_code], client)
    else
      oauth2_error('unsupported_grant_type')
    end
  end

  # rubocop:enable MethodLength
  def destroy
    oauth2_error('unsupported_token_type') && return unless params[:token_type_hint] == 'access_token'

    login = Login.where(oauth2_token: params[:token]).first || LoginNotFound.new
    login.refresh_oauth2_token!

    head 200
  end

  private

    def authenticate_with_credentials(identification, password, provider, client)
      client ||= DEFAULT_CLIENT_NAME  # in case of subclass invocation

      logins = Login.where(identification: identification)

      login = logins.find_by(provider: provider, client: client)
      login ||= logins.find_by(provider: nil, client: nil) || LoginNotFound.new  # for existing users

      if login.authenticate(password)
        render json: { access_token: login.oauth2_token }
      else
        oauth2_error('invalid_grant')
      end
    end

    def authenticate_with_facebook(auth_code, client)
      oauth2_error('no_authorization_code') && return unless auth_code.present?

      login = FacebookAuthenticator.new(auth_code, client).authenticate!

      render json: { access_token: login.oauth2_token }
    rescue FacebookAuthenticator::ApiError
      render nothing: true, status: 502
    end

    def authenticate_with_google(auth_code, client)
      oauth2_error('no_authorization_code') && return unless auth_code.present?

      authenticator = GoogleAuthenticator.new(auth_code, client)
      login = authenticator.authenticate!

      render json: { access_token: login.oauth2_token }.merge(authenticator.google_user)
    rescue GoogleAuthenticator::ApiError
      render nothing: true, status: 502
    end

    def authenticate_with_edx(username, auth_code, client)
      oauth2_error('no_authorization_code') && return unless auth_code.present?
      oauth2_error('no_username') && return unless username.present?

      login = EdxAuthenticator.new(username, auth_code, client).authenticate!

      render json: { access_token: login.oauth2_token }
    rescue EdxAuthenticator::ApiError
      render nothing: true, status: 502
    end

    def oauth2_error(error)
      render json: { error: error }, status: 400
    end

end
