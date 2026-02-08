module Api
  module V1
    class PaymentsController < BaseController
      before_action :set_payment, only: [:show]

      def index
        authorize Payment
        @payments = policy_scope(Payment).includes(:repair_ticket)
        
        # Filters
        @payments = @payments.where(repair_ticket_id: params[:repair_ticket_id]) if params[:repair_ticket_id].present?
        @payments = @payments.where(payment_method: params[:payment_method]) if params[:payment_method].present?
        
        if params[:start_date].present? && params[:end_date].present?
          @payments = @payments.where(created_at: params[:start_date]..params[:end_date])
        end
        
        @payments = @payments.order(created_at: :desc)
                             .page(params[:page] || 1)
                             .per(params[:per_page] || 25)
        
        render json: {
          payments: @payments.as_json(
            include: {
              repair_ticket: { 
                only: [:id, :ticket_number, :quoted_price],
                include: {
                  customer: { only: [:id, :first_name, :last_name], methods: [:full_name] }
                }
              }
            }
          ),
          meta: pagination_metadata(@payments)
        }
      end

      def show
        authorize @payment
        
        render json: {
          payment: @payment.as_json(
            include: {
              repair_ticket: {
                only: [:id, :ticket_number, :quoted_price, :actual_price],
                include: {
                  customer: { only: [:id, :first_name, :last_name, :phone, :email], methods: [:full_name] },
                  device: { only: [:id, :device_type, :brand, :model] }
                }
              }
            }
          )
        }
      end

      def create
        @payment = Payment.new(payment_params)
        authorize @payment
        
        # Validate payment amount
        ticket = RepairTicket.find(payment_params[:repair_ticket_id])
        total_paid = ticket.payments.sum(:amount)
        quoted_price = ticket.quoted_price || 0
        balance = quoted_price - total_paid
        
        if @payment.amount > balance
          return render_error(
            "Payment amount (#{@payment.amount}) exceeds remaining balance (#{balance})",
            status: :unprocessable_entity
          )
        end
        
        ActiveRecord::Base.transaction do
          if @payment.save!
            # Create activity log
            ActivityLog.create!(
              repair_ticket: ticket,
              user: current_user,
              action_type: 'payment_received',
              description: "Payment of #{@payment.amount} received via #{@payment.payment_method}"
            )
            
            # Update ticket status if fully paid
            new_balance = balance - @payment.amount
            if new_balance <= 0 && ticket.status == 'completed'
              ticket.update(status: 'collected')
            end
            
            render json: {
              payment: @payment.as_json(
                include: {
                  repair_ticket: { only: [:id, :ticket_number] }
                }
              ),
              balance: new_balance
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
      rescue ActiveRecord::RecordNotFound
        render_error('Repair ticket not found', status: :not_found)
      end

      private

      def set_payment
        @payment = Payment.find(params[:id])
      end

      def payment_params
        params.require(:payment).permit(
          :repair_ticket_id, :amount, :payment_method, :reference_number, :notes
        )
      end
    end
  end
end
