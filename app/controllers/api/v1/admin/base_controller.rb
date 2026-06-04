module Api
  module V1
    module Admin
      class BaseController < ApplicationController
        before_action :authorize_admin!
        before_action :enforce_rate_limit!
        around_action :observe_admin_action

        private

        def authorize_admin!
          render_forbidden unless current_user&.admin?
        end

        def enforce_rate_limit!
          ::Admin::RateLimiter.new.call(
            user: current_user,
            action_name: admin_action_name,
            limit: admin_rate_limit.fetch(:limit),
            period: admin_rate_limit.fetch(:period)
          )
        rescue ::Admin::RateLimiter::LimitExceeded => error
          @admin_action_status = :rate_limited
          log_admin_action(:rate_limited)
          @skip_admin_action_log = true
          render_too_many_requests(error.message)
        end

        def observe_admin_action
          yield
          @admin_action_status ||= response.successful? ? :accepted : status_to_log_status
        rescue StandardError
          @admin_action_status = :error
          raise
        ensure
          log_admin_action(@admin_action_status || status_to_log_status) unless @skip_admin_action_log
        end

        def admin_rate_limit
          { limit: 5, period: 15.minutes }
        end

        def admin_action_name
          "#{controller_name}##{action_name}"
        end

        def admin_log_metadata
          {
            params: request.filtered_parameters.except("controller", "action"),
            response_status: response.status
          }
        end

        def log_admin_action(status)
          return unless current_user&.admin?

          payload = {
            user_id: current_user.id,
            action_name: admin_action_name,
            status: status,
            metadata: admin_log_metadata
          }

          AdminActionLog.create!(
            user: current_user,
            action_name: payload[:action_name],
            status: payload[:status],
            metadata: payload[:metadata],
            occurred_at: Time.current
          )
          ActiveSupport::Notifications.instrument("admin_action.conqurun", payload)
        end

        def status_to_log_status
          response.forbidden? ? :forbidden : :error
        end
      end
    end
  end
end
