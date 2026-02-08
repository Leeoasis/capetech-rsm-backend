json.invoice do
  json.invoice_number @invoice_number
  json.created_at Time.current.iso8601
  
  json.customer do
    json.id @customer.id
    json.name "#{@customer.first_name} #{@customer.last_name}"
    json.email @customer.email
    json.phone @customer.phone
  end
  
  if @device
    json.device do
      json.id @device.id
      json.device_type @device.device_type
      json.brand @device.brand
      json.model @device.model
      json.serial_number @device.serial_number
    end
  end
  
  if @repair_ticket
    json.repair_ticket do
      json.partial! 'api/v1/repair_tickets/repair_ticket', repair_ticket: @repair_ticket
    end
  end
  
  json.total_amount @total_amount
  json.deposit_paid @deposit_paid
  json.balance_due @balance_due
end
