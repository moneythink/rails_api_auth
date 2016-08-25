class BaseAuthenticator

  class ApiError < StandardError; end

  def initialize(auth_code, client)
    @auth_code = auth_code
    @client    = client
  end

  def authenticate!
    user = get_user(access_token)
    provider = self.class::PROVIDER
    identification = user[:email]
    login = find_login(provider, @client, identification)
    uid = get_uid(user)

    if login.present?
      connect_login_to_account(login, uid, provider, @client)
    else
      login = create_login_from_account(@client, identification, uid)
    end

    login
  end

  private

    def find_login(provider, client, identification)
      login_record = Login.where(provider: provider, client: client, identification: identification).first
      return login_record unless login_record.nil?
      Login.where(provider: nil, client: nil, identification: identification).first
    end

    def connect_login_to_account(login, uid, provider, client)
      # provider & client are populated for records that existed pre-concurrent logins
      login.update_attributes!(uid: uid, provider: provider, client: client)
    end

    def create_login_from_account(client, identification, uid)
      login_attributes = {
        provider: self.class::PROVIDER,
        client: client,
        identification: identification,
        uid: uid
      }
      Login.create!(login_attributes)
    end

    def get_request(url)
      response = HTTParty.get(url)
      unless response.code == 200
        Rails.logger.warn "#{self.class::PROVIDER} API request failed with status #{response.code}."
        Rails.logger.debug "#{self.class::PROVIDER} API error response was:\n#{response.body}"
        raise ApiError.new
      end
      response
    end

end
