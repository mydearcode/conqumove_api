module Auth
  class TokenRefresher
    def call(refresh_token:)
      token = ApiToken.authenticate(refresh_token, token_kind: :refresh)
      raise ArgumentError, "Invalid refresh token" unless token

      issued = Auth::TokenIssuer.new.call(user: token.user)
      token.revoke!(replacement: issued.refresh_token_record)
      issued
    end
  end
end
