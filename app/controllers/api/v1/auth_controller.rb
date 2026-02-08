module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: [:login, :refresh]

      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          access_token = JwtService.encode({ user_id: user.id }, token_type: :access)
          refresh_token = create_refresh_token(user)

          render json: {
            user: user_data(user),
            access_token: access_token,
            refresh_token: refresh_token.token
          }, status: :ok
        else
          render json: {
            error: {
              message: 'Invalid email or password',
              details: {}
            }
          }, status: :unauthorized
        end
      end

      def refresh
        token = params[:refresh_token]
        refresh_token = RefreshToken.find_by(token: token)

        if refresh_token&.expired?
          refresh_token.destroy
          render json: {
            error: {
              message: 'Refresh token expired',
              details: {}
            }
          }, status: :unauthorized
        elsif refresh_token
          access_token = JwtService.encode({ user_id: refresh_token.user_id }, token_type: :access)
          render json: { access_token: access_token }, status: :ok
        else
          render json: {
            error: {
              message: 'Invalid refresh token',
              details: {}
            }
          }, status: :unauthorized
        end
      end

      def logout
        token = params[:refresh_token]
        refresh_token = RefreshToken.find_by(token: token)

        if refresh_token
          refresh_token.destroy
          render json: { message: 'Logged out successfully' }, status: :ok
        else
          render json: {
            error: {
              message: 'Invalid refresh token',
              details: {}
            }
          }, status: :unauthorized
        end
      end

      def me
        render json: { user: user_data(current_user) }, status: :ok
      end

      private

      def create_refresh_token(user)
        user.refresh_tokens.create!(
          expires_at: Time.current + JwtService::REFRESH_TOKEN_EXPIRATION
        )
      end

      def user_data(user)
        {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          role: user.role,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end

      def skip_authentication?
        action_name == 'login' || action_name == 'refresh'
      end

      def skip_authorization?
        true
      end
    end
  end
end
