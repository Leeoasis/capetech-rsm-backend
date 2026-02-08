module Api
  module V1
    class DevicesController < BaseController
      before_action :set_device, only: [:show, :update, :destroy]

      def index
        authorize Device
        @devices = policy_scope(Device).includes(:customer)
        
        @devices = @devices.where(customer_id: params[:customer_id]) if params[:customer_id].present?
        @devices = @devices.where(device_type: params[:device_type]) if params[:device_type].present?
        @devices = @devices.page(params[:page] || 1).per(params[:per_page] || 25)
        
        render json: {
          devices: @devices.as_json(
            include: {
              customer: { only: [:id, :first_name, :last_name], methods: [:full_name] }
            }
          ),
          meta: pagination_metadata(@devices)
        }
      end

      def show
        authorize @device
        
        render json: {
          device: @device.as_json(
            include: {
              customer: { only: [:id, :first_name, :last_name], methods: [:full_name] },
              repair_tickets: { only: [:id, :ticket_number, :status, :created_at] }
            }
          )
        }
      end

      def create
        @device = Device.new(device_params)
        authorize @device
        
        if @device.save
          render json: {
            device: @device.as_json(
              include: {
                customer: { only: [:id, :first_name, :last_name], methods: [:full_name] }
              }
            )
          }, status: :created
        else
          render json: {
            error: {
              message: 'Validation failed',
              details: @device.errors.messages
            }
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @device
        
        if @device.update(device_params)
          render json: {
            device: @device.as_json(
              include: {
                customer: { only: [:id, :first_name, :last_name], methods: [:full_name] }
              }
            )
          }
        else
          render json: {
            error: {
              message: 'Validation failed',
              details: @device.errors.messages
            }
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @device
        
        @device.destroy
        head :no_content
      end

      private

      def set_device
        @device = Device.find(params[:id])
      end

      def device_params
        params.require(:device).permit(
          :customer_id, :device_type, :brand, :model, :serial_number,
          :imei, :password_pin, :notes
        )
      end
    end
  end
end
