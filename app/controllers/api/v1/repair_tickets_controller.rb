module Api
  module V1
    class RepairTicketsController < BaseController
      before_action :set_repair_ticket, only: [:show, :update, :destroy, :update_status, :timeline, :payments]

      def index
        authorize RepairTicket
        @tickets = policy_scope(RepairTicket)
                     .includes(:customer, :device, :assigned_technician)
        
        # Filters
        @tickets = @tickets.by_status(params[:status]) if params[:status].present?
        @tickets = @tickets.by_technician(params[:technician_id]) if params[:technician_id].present?
        @tickets = @tickets.by_priority(params[:priority]) if params[:priority].present?
        
        if params[:start_date].present? && params[:end_date].present?
          @tickets = @tickets.where(created_at: params[:start_date]..params[:end_date])
        end
        
        @tickets = @tickets.page(params[:page] || 1).per(params[:per_page] || 25)
        
        render json: {
          repair_tickets: @tickets.as_json(
            include: {
              customer: { only: [:id, :first_name, :last_name], methods: [:full_name] },
              device: { only: [:id, :device_type, :brand, :model] },
              assigned_technician: { only: [:id, :first_name, :last_name], methods: [:full_name] }
            }
          ),
          meta: pagination_metadata(@tickets)
        }
      end

      def show
        authorize @ticket
        
        render json: {
          repair_ticket: @ticket.as_json(
            include: {
              customer: { only: [:id, :first_name, :last_name, :phone, :email], methods: [:full_name] },
              device: { only: [:id, :device_type, :brand, :model, :serial_number, :imei] },
              assigned_technician: { only: [:id, :first_name, :last_name, :email], methods: [:full_name] },
              payments: { only: [:id, :amount, :payment_method, :created_at] },
              repair_statuses: { only: [:id, :status, :notes, :created_at], include: { user: { only: [:id, :first_name, :last_name] } } }
            }
          )
        }
      end

      def create
        @ticket = RepairTicket.new(repair_ticket_params)
        @ticket.status = :pending
        authorize @ticket
        
        ActiveRecord::Base.transaction do
          if @ticket.save!
            # Create initial activity log
            ActivityLog.create!(
              repair_ticket: @ticket,
              user: current_user,
              action_type: 'created',
              description: "Ticket created with status: pending"
            )
            
            render json: {
              repair_ticket: @ticket.as_json(
                include: {
                  customer: { only: [:id, :first_name, :last_name], methods: [:full_name] },
                  device: { only: [:id, :device_type, :brand, :model] }
                }
              )
            }, status: :created
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: {
          error: {
            message: 'Validation failed',
            details: e.record.errors.messages
          }
        }, status: :unprocessable_entity
      end

      def update
        authorize @ticket
        
        ActiveRecord::Base.transaction do
          if @ticket.update(repair_ticket_params)
            # Log the update
            ActivityLog.create!(
              repair_ticket: @ticket,
              user: current_user,
              action_type: 'updated',
              description: "Ticket updated"
            )
            
            render json: {
              repair_ticket: @ticket.as_json(
                include: {
                  customer: { only: [:id, :first_name, :last_name], methods: [:full_name] },
                  device: { only: [:id, :device_type, :brand, :model] },
                  assigned_technician: { only: [:id, :first_name, :last_name], methods: [:full_name] }
                }
              )
            }
          else
            render json: {
              error: {
                message: 'Validation failed',
                details: @ticket.errors.messages
              }
            }, status: :unprocessable_entity
          end
        end
      end

      def destroy
        authorize @ticket
        
        @ticket.destroy
        head :no_content
      end

      def update_status
        authorize @ticket, :update?
        
        new_status = params[:status]
        notes = params[:notes]
        
        unless RepairTicket.statuses.key?(new_status)
          return render_error("Invalid status: #{new_status}", status: :bad_request)
        end
        
        ActiveRecord::Base.transaction do
          # Update ticket status
          @ticket.update!(status: new_status)
          
          # Create repair status record
          RepairStatus.create!(
            repair_ticket: @ticket,
            user: current_user,
            status: new_status,
            notes: notes
          )
          
          # Create activity log
          ActivityLog.create!(
            repair_ticket: @ticket,
            user: current_user,
            action_type: 'status_changed',
            description: "Status changed to #{new_status}"
          )
          
          render json: {
            repair_ticket: @ticket.as_json(
              include: {
                repair_statuses: { include: { user: { only: [:id, :first_name, :last_name] } } }
              }
            )
          }
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: {
          error: {
            message: 'Failed to update status',
            details: e.record.errors.messages
          }
        }, status: :unprocessable_entity
      end

      def timeline
        authorize @ticket, :show?
        
        statuses = @ticket.repair_statuses.order(created_at: :asc).as_json(
          include: { user: { only: [:id, :first_name, :last_name], methods: [:full_name] } }
        )
        
        logs = @ticket.activity_logs.order(created_at: :asc).as_json(
          include: { user: { only: [:id, :first_name, :last_name], methods: [:full_name] } }
        )
        
        timeline = (statuses + logs).sort_by { |item| item['created_at'] }
        
        render json: { timeline: timeline }
      end

      def payments
        authorize @ticket, :show?
        
        @payments = @ticket.payments.order(created_at: :desc)
        total_paid = @payments.sum(:amount)
        balance = (@ticket.quoted_price || 0) - total_paid
        
        render json: {
          payments: @payments,
          summary: {
            quoted_price: @ticket.quoted_price,
            total_paid: total_paid,
            balance: balance
          }
        }
      end

      def kanban
        authorize RepairTicket, :index?
        
        tickets = policy_scope(RepairTicket).includes(:customer, :device, :assigned_technician)
        
        kanban_data = RepairTicket.statuses.keys.map do |status|
          status_tickets = tickets.by_status(status)
          {
            status: status,
            count: status_tickets.count,
            tickets: status_tickets.limit(20).as_json(
              only: [:id, :ticket_number, :priority, :created_at],
              include: {
                customer: { only: [:id, :first_name, :last_name], methods: [:full_name] },
                device: { only: [:id, :device_type, :brand, :model] },
                assigned_technician: { only: [:id, :first_name, :last_name], methods: [:full_name] }
              }
            )
          }
        end
        
        render json: { kanban: kanban_data }
      end

      private

      def set_repair_ticket
        @ticket = RepairTicket.find(params[:id])
      end

      def repair_ticket_params
        params.require(:repair_ticket).permit(
          :customer_id, :device_id, :assigned_technician_id, :fault_description,
          :diagnosis, :repair_notes, :priority, :quoted_price, :actual_price,
          :estimated_completion, :completed_at, :collected_at
        )
      end
    end
  end
end
