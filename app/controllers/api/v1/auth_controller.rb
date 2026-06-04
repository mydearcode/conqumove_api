module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[register login refresh]

      def register
        user = User.create!(registration_params)
        issued = Auth::TokenIssuer.new.call(user: user)

        render json: auth_payload(issued), status: :created
      end

      def login
        user = User.find_by!(email: login_params[:email].to_s.strip.downcase)
        raise ArgumentError, "Invalid email or password" unless user.authenticate(login_params[:password])

        issued = Auth::TokenIssuer.new.call(user: user)
        render json: auth_payload(issued)
      end

      def refresh
        issued = Auth::TokenRefresher.new.call(refresh_token: refresh_params[:refresh_token])
        render json: auth_payload(issued)
      end

      def logout
        current_api_token.destroy!
        head :no_content
      end

      def me
        render json: {
          id: current_user.id,
          email: current_user.email
        }
      end

      private

      def registration_params
        params.permit(:email, :password, :password_confirmation)
      end

      def login_params
        params.permit(:email, :password)
      end

      def refresh_params
        params.permit(:refresh_token)
      end

      def auth_payload(issued)
        {
          user: {
            id: issued.user.id,
            email: issued.user.email
          },
          access_token: issued.access_token,
          access_token_expires_at: issued.access_token_record.expires_at,
          refresh_token: issued.refresh_token,
          refresh_token_expires_at: issued.refresh_token_record.expires_at
        }
      end
    end
  end
end
