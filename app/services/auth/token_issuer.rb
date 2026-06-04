module Auth
  class TokenIssuer
    Result = Struct.new(
      :user,
      :access_token_record,
      :access_token,
      :refresh_token_record,
      :refresh_token,
      keyword_init: true
    )

    def call(user:)
      access_record, access_token = ApiToken.issue_for(
        user: user,
        token_kind: :access,
        expires_at: ApiToken::ACCESS_TOKEN_TTL.from_now
      )
      refresh_record, refresh_token = ApiToken.issue_for(
        user: user,
        token_kind: :refresh,
        expires_at: ApiToken::REFRESH_TOKEN_TTL.from_now
      )

      Result.new(
        user: user,
        access_token_record: access_record,
        access_token: access_token,
        refresh_token_record: refresh_record,
        refresh_token: refresh_token
      )
    end
  end
end
