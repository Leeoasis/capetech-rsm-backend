module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [:show, :update]

      def index
        authorize User
        @users = policy_scope(User)
                   .page(params[:page] || 1)
                   .per(params[:per_page] || 25)
        
        render json: {
          users: @users.as_json(
            only: [:id, :email, :first_name, :last_name, :role, :created_at, :updated_at],
            methods: [:full_name]
          ),
          meta: pagination_metadata(@users)
        }
      end

      def show
        authorize @user
        
        render json: {
          user: @user.as_json(
            only: [:id, :email, :first_name, :last_name, :role, :created_at, :updated_at],
            methods: [:full_name]
          )
        }
      end

      def create
        @user = User.new(user_create_params)
        authorize @user
        
        if @user.save
          render json: {
            user: @user.as_json(
              only: [:id, :email, :first_name, :last_name, :role, :created_at, :updated_at],
              methods: [:full_name]
            )
          }, status: :created
        else
          render json: {
            error: {
              message: 'Validation failed',
              details: @user.errors.messages
            }
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @user
        
        if @user.update(user_update_params)
          render json: {
            user: @user.as_json(
              only: [:id, :email, :first_name, :last_name, :role, :created_at, :updated_at],
              methods: [:full_name]
            )
          }
        else
          render json: {
            error: {
              message: 'Validation failed',
              details: @user.errors.messages
            }
          }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_create_params
        params.require(:user).permit(
          :email, :password, :password_confirmation, :first_name, :last_name, :role
        )
      end

      def user_update_params
        params.require(:user).permit(
          :email, :first_name, :last_name, :role, :password, :password_confirmation
        )
      end
    end
  end
end
