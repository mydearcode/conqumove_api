module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token].presence || bearer_token
      api_token = ApiToken.authenticate(token)
      reject_unauthorized_connection unless api_token

      api_token.user
    end

    def bearer_token
      authorization = request.headers["Authorization"].to_s
      scheme, token = authorization.split(" ", 2)
      return if scheme.to_s.downcase != "bearer"

      token
    end
  end
end
