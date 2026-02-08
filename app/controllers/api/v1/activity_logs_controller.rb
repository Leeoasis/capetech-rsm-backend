module Api
  module V1
    class ActivityLogsController < BaseController
      before_action :set_activity_log, only: [:show]

      def index
        authorize ActivityLog
        @logs = policy_scope(ActivityLog).includes(:user, :repair_ticket)
        
        # Filters
        @logs = @logs.where(repair_ticket_id: params[:repair_ticket_id]) if params[:repair_ticket_id].present?
        @logs = @logs.where(user_id: params[:user_id]) if params[:user_id].present?
        @logs = @logs.where(action_type: params[:action_type]) if params[:action_type].present?
        
        @logs = @logs.order(created_at: :desc)
                     .page(params[:page] || 1)
                     .per(params[:per_page] || 25)
        
        render json: {
          activity_logs: @logs.as_json(
            include: {
              user: { only: [:id, :first_name, :last_name, :email], methods: [:full_name] },
              repair_ticket: { only: [:id, :ticket_number] }
            }
          ),
          meta: pagination_metadata(@logs)
        }
      end

      def show
        authorize @log
        
        render json: {
          activity_log: @log.as_json(
            include: {
              user: { only: [:id, :first_name, :last_name, :email], methods: [:full_name] },
              repair_ticket: { 
                only: [:id, :ticket_number, :status],
                include: {
                  customer: { only: [:id, :first_name, :last_name], methods: [:full_name] }
                }
              }
            }
          )
        }
      end

      private

      def set_activity_log
        @log = ActivityLog.find(params[:id])
      end
    end
  end
end
