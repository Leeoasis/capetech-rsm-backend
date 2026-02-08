module Api
  module V1
    class CustomersController < BaseController
      before_action :set_customer, only: [:show, :update, :destroy, :devices, :repair_tickets]

      def index
        authorize Customer
        @customers = policy_scope(Customer)
        
        @customers = @customers.by_name_or_phone(params[:search]) if params[:search].present?
        @customers = @customers.page(params[:page] || 1).per(params[:per_page] || 25)
        
        render json: {
          customers: @customers.as_json(methods: [:full_name]),
          meta: pagination_metadata(@customers)
        }
      end

      def show
        authorize @customer
        
        render json: {
          customer: @customer.as_json(
            methods: [:full_name],
            include: {
              devices: { only: [:id, :device_type, :brand, :model, :serial_number] }
            }
          )
        }
      end

      def create
        @customer = Customer.new(customer_params)
        authorize @customer
        
        if @customer.save
          render json: {
            customer: @customer.as_json(methods: [:full_name])
          }, status: :created
        else
          render json: {
            error: {
              message: 'Validation failed',
              details: @customer.errors.messages
            }
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @customer
        
        if @customer.update(customer_params)
          render json: {
            customer: @customer.as_json(methods: [:full_name])
          }
        else
          render json: {
            error: {
              message: 'Validation failed',
              details: @customer.errors.messages
            }
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @customer
        
        @customer.soft_delete
        head :no_content
      end

      def devices
        authorize @customer
        
        @devices = @customer.devices.page(params[:page] || 1).per(params[:per_page] || 25)
        
        render json: {
          devices: @devices,
          meta: pagination_metadata(@devices)
        }
      end

      def repair_tickets
        authorize @customer
        
        @tickets = @customer.repair_tickets
                            .includes(:device, :assigned_technician)
                            .page(params[:page] || 1)
                            .per(params[:per_page] || 25)
        
        render json: {
          repair_tickets: @tickets.as_json(
            include: {
              device: { only: [:id, :device_type, :brand, :model] },
              assigned_technician: { only: [:id, :first_name, :last_name], methods: [:full_name] }
            }
          ),
          meta: pagination_metadata(@tickets)
        }
      end

      private

      def set_customer
        @customer = Customer.find(params[:id])
      end

      def customer_params
        params.require(:customer).permit(
          :first_name, :last_name, :email, :phone, :address, :city, 
          :state, :zip_code, :notes, :active
        )
      end

      def full_name
        "#{first_name} #{last_name}"
      end
    end
  end
end
