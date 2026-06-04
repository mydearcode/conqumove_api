module Api
  module V1
    module Admin
      class BaseController < ApplicationController
        before_action :authorize_admin!

        private

        def authorize_admin!
          render_forbidden unless current_user&.admin?
        end
      end
    end
  end
end
