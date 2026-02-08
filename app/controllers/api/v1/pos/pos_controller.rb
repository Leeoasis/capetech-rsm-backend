module Api
  module V1
    module Pos
      class PosController < BaseController
        def create_invoice
          authorize :pos, :create?
          
          customer = Customer.find(params[:customer_id])
          device = Device.find(params[:device_id])
          
          parts_cost = params[:parts_cost].to_f || 0
          labor_cost = params[:labor_cost].to_f || 0
          total = parts_cost + labor_cost
          
          ActiveRecord::Base.transaction do
            # Create repair ticket
            ticket = RepairTicket.create!(
              customer: customer,
              device: device,
              fault_description: params[:fault_description],
              accessories_received: params[:accessories_received],
              priority: params[:priority] || 'medium',
              estimated_cost: total,
              actual_cost: total,
              status: :pending
            )
            
            # Create initial activity log
            ActivityLog.create!(
              repair_ticket: ticket,
              user: current_user,
              action_type: 'invoice_created',
              description: "Invoice created. Parts: #{parts_cost}, Labor: #{labor_cost}, Total: #{total}"
            )
            
            render json: {
              invoice: {
                ticket_number: ticket.ticket_number,
                customer: customer.as_json(only: [:id, :first_name, :last_name, :phone], methods: [:full_name]),
                device: device.as_json(only: [:id, :device_type, :brand, :model]),
                parts_cost: parts_cost,
                labor_cost: labor_cost,
                total: total,
                created_at: ticket.created_at
              },
              repair_ticket_id: ticket.id
            }, status: :created
          end
        rescue ActiveRecord::RecordNotFound => e
          render_error(e.message, status: :not_found)
        rescue ActiveRecord::RecordInvalid => e
          render json: {
            error: {
              message: 'Validation failed',
              details: e.record.errors.messages
            }
          }, status: :unprocessable_entity
        end

        def process_payment
          authorize :pos, :create?
          
          ticket = RepairTicket.find(params[:repair_ticket_id])
          amount = params[:amount].to_f
          payment_method = params[:payment_method]
          
          # Calculate current balance
          total_paid = ticket.payments.sum(:amount)
          estimated_cost = ticket.estimated_cost || 0
          balance = estimated_cost - total_paid
          
          if amount > balance
            return render_error(
              "Payment amount (#{amount}) exceeds remaining balance (#{balance})",
              status: :unprocessable_entity
            )
          end
          
          ActiveRecord::Base.transaction do
            # Create payment
            payment = Payment.create!(
              repair_ticket: ticket,
              amount: amount,
              payment_method: payment_method,
              reference_number: params[:reference_number],
              notes: params[:notes]
            )
            
            # Create activity log
            ActivityLog.create!(
              repair_ticket: ticket,
              user: current_user,
              action_type: 'payment_received',
              description: "Payment of #{amount} received via #{payment_method}"
            )
            
            # Update ticket status if fully paid
            new_balance = balance - amount
            if new_balance <= 0 && ticket.completed?
              ticket.update!(status: :collected, collected_at: Time.current)
              
              ActivityLog.create!(
                repair_ticket: ticket,
                user: current_user,
                action_type: 'status_changed',
                description: "Status changed to collected (fully paid)"
              )
            end
            
            receipt_data = generate_receipt_data(ticket, payment, new_balance)
            
            render json: {
              payment: payment.as_json(only: [:id, :amount, :payment_method, :created_at]),
              receipt: receipt_data
            }, status: :created
          end
        rescue ActiveRecord::RecordNotFound => e
          render_error(e.message, status: :not_found)
        rescue ActiveRecord::RecordInvalid => e
          render json: {
            error: {
              message: 'Validation failed',
              details: e.record.errors.messages
            }
          }, status: :unprocessable_entity
        end

        def receipt
          authorize :pos, :show?
          
          payment = Payment.find(params[:id])
          ticket = payment.repair_ticket
          
          total_paid = ticket.payments.where('id <= ?', payment.id).sum(:amount)
          balance = (ticket.estimated_cost || 0) - total_paid
          
          receipt_data = generate_receipt_data(ticket, payment, balance)
          
          render json: { receipt: receipt_data }
        rescue ActiveRecord::RecordNotFound => e
          render_error(e.message, status: :not_found)
        end

        private

        def generate_receipt_data(ticket, payment, balance)
          {
            ticket_number: ticket.ticket_number,
            payment_id: payment.id,
            date: payment.created_at,
            customer: {
              name: ticket.customer.full_name,
              phone: ticket.customer.phone,
              email: ticket.customer.email
            },
            device: {
              type: ticket.device.device_type,
              brand: ticket.device.brand,
              model: ticket.device.model
            },
            payment: {
              amount: payment.amount,
              method: payment.payment_method,
              reference: payment.reference_number
            },
            financial: {
              estimated_cost: ticket.estimated_cost,
              total_paid: ticket.payments.sum(:amount),
              balance: balance,
              status: balance <= 0 ? 'Paid in Full' : 'Partial Payment'
            },
            fault_description: ticket.fault_description,
            accessories_received: ticket.accessories_received
          }
        end
      end
    end
  end
end
