module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[register login]

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

      def auth_payload(issued)
        {
          user: {
            id: issued.user.id,
            email: issued.user.email
          },
          access_token: issued.token,
          expires_at: issued.api_token.expires_at
        }
      end
    end
  end
end
