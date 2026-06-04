class ApplicationController < ActionController::API
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity
  rescue_from ArgumentError, with: :render_unprocessable_entity

  private

  attr_reader :current_user, :current_api_token

  def authenticate_user!
    token = bearer_token
    return render_unauthorized if token.blank?

    api_token = ApiToken.authenticate(token, token_kind: :access)
    return render_unauthorized unless api_token

    api_token.touch(:last_used_at)
    @current_api_token = api_token
    @current_user = api_token.user
  end

  def bearer_token
    authorization = request.authorization.to_s
    scheme, token = authorization.split(" ", 2)
    return if scheme.to_s.downcase != "bearer"

    token
  end

  def render_not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  def render_unprocessable_entity(error)
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def render_forbidden
    render json: { error: "Forbidden" }, status: :forbidden
  end
end
