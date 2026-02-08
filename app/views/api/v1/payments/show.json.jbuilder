json.payment do
  json.partial! 'api/v1/payments/payment', payment: @payment
  
  if @payment.repair_ticket
    json.repair_ticket do
      json.extract! @payment.repair_ticket, :id, :ticket_number, :status, :issue_description,
                    :estimated_cost, :final_cost, :deposit_amount
      json.created_at @payment.repair_ticket.created_at.iso8601
      
      if @payment.repair_ticket.customer
        json.customer do
          json.id @payment.repair_ticket.customer.id
          json.name "#{@payment.repair_ticket.customer.first_name} #{@payment.repair_ticket.customer.last_name}"
          json.email @payment.repair_ticket.customer.email
          json.phone @payment.repair_ticket.customer.phone
        end
      end
      
      if @payment.repair_ticket.device
        json.device do
          json.id @payment.repair_ticket.device.id
          json.device_type @payment.repair_ticket.device.device_type
          json.brand @payment.repair_ticket.device.brand
          json.model @payment.repair_ticket.device.model
        end
      end
    end
  end
end
