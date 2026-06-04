module Auth
  class TokenIssuer
    Result = Struct.new(:user, :api_token, :token, keyword_init: true)

    def call(user:)
      api_token, token = ApiToken.issue_for(user: user)
      Result.new(user: user, api_token: api_token, token: token)
    end
  end
end
