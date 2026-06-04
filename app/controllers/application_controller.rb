class ApplicationController < ActionController::API
  before_action :authenticate_user!
  before_action :enforce_public_rate_limit!, if: :public_rate_limit_enabled?

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
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

  def public_rate_limit_enabled?
    public_rate_limit_config.present?
  end

  def public_rate_limit_config
    nil
  end

  def public_rate_limit_scope
    "#{controller_path}##{action_name}"
  end

  def public_rate_limit_actor
    current_user&.id || request.remote_ip || "anonymous"
  end

  def enforce_public_rate_limit!
    config = public_rate_limit_config
    return unless config

    ::PublicApi::RateLimiter.new.call(
      scope: public_rate_limit_scope,
      actor: public_rate_limit_actor,
      limit: config.fetch(:limit),
      period: config.fetch(:period)
    )
  rescue ::PublicApi::RateLimiter::LimitExceeded => error
    response.set_header("Retry-After", error.retry_after.to_i.to_s)
    render_too_many_requests(
      "Rate limit exceeded",
      code: "rate_limited",
      details: {
        scope: error.scope,
        retry_after: error.retry_after
      }
    )
  end

  def bearer_token
    authorization = request.authorization.to_s
    scheme, token = authorization.split(" ", 2)
    return if scheme.to_s.downcase != "bearer"

    token
  end

  def render_not_found(error)
    render_api_error(status: :not_found, code: "not_found", message: error.message)
  end

  def render_record_invalid(error)
    render_api_error(
      status: :unprocessable_entity,
      code: "validation_error",
      message: "Validation failed",
      details: error.record.errors.to_hash
    )
  end

  def render_unprocessable_entity(error)
    details = error.is_a?(ActionController::ParameterMissing) ? { parameter: error.param } : nil
    render_api_error(
      status: :unprocessable_entity,
      code: "unprocessable_entity",
      message: error.message,
      details: details
    )
  end

  def render_unauthorized(message = "Unauthorized", code: "unauthorized", details: nil)
    render_api_error(status: :unauthorized, code: code, message: message, details: details)
  end

  def render_forbidden(message = "Forbidden", code: "forbidden", details: nil)
    render_api_error(status: :forbidden, code: code, message: message, details: details)
  end

  def render_too_many_requests(message = "Too Many Requests", code: "too_many_requests", details: nil)
    render_api_error(status: :too_many_requests, code: code, message: message, details: details)
  end

  def render_api_error(status:, code:, message:, details: nil)
    payload = {
      error: {
        code: code,
        message: message,
        details: details
      },
      request_id: request.request_id
    }

    render json: payload, status: status
  end

  def public_base_url
    Rails.application.config.x.public_base_url.presence || request.base_url
  end

  def public_cable_url
    Rails.application.config.x.public_cable_url.presence || "#{public_base_url}/cable"
  end
end
