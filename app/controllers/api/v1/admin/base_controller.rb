module Api
  module V1
    module Admin
      class BaseController < ActionController::API
        before_action :authenticate_admin!

        private

        def authenticate_admin!
          provided = request.headers["X-Admin-Token"].to_s
          expected = ENV.fetch("CONQURUN_ADMIN_TOKEN", "development-admin-token")
          head :unauthorized unless provided.present? && ActiveSupport::SecurityUtils.secure_compare(provided, expected)
        end
      end
    end
  end
end
