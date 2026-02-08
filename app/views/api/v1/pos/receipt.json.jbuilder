json.receipt do
  json.receipt_number @receipt_number
  json.date Time.current.iso8601
  
  json.business do
    json.name @business_name || "Cape Tech Repair Shop"
    json.address @business_address
    json.phone @business_phone
    json.email @business_email
  end
  
  json.customer do
    json.name "#{@repair_ticket.customer.first_name} #{@repair_ticket.customer.last_name}"
    json.email @repair_ticket.customer.email
    json.phone @repair_ticket.customer.phone
  end
  
  json.ticket do
    json.ticket_number @repair_ticket.ticket_number
    json.issue_description @repair_ticket.issue_description
    json.status @repair_ticket.status
  end
  
  if @repair_ticket.device
    json.device do
      json.device_type @repair_ticket.device.device_type
      json.brand @repair_ticket.device.brand
      json.model @repair_ticket.device.model
      json.serial_number @repair_ticket.device.serial_number
    end
  end
  
  json.charges do
    json.estimated_cost @repair_ticket.estimated_cost
    json.final_cost @repair_ticket.final_cost
    json.deposit_amount @repair_ticket.deposit_amount
  end
  
  json.payments @repair_ticket.payments.order(created_at: :desc) do |payment|
    json.date payment.payment_date || payment.created_at.to_date
    json.amount payment.amount
    json.method payment.payment_method
    json.reference_number payment.reference_number
  end
  
  json.totals do
    json.subtotal @repair_ticket.final_cost || @repair_ticket.estimated_cost
    json.total_paid @repair_ticket.payments.sum(:amount)
    json.balance_due (@repair_ticket.final_cost || @repair_ticket.estimated_cost || 0) - @repair_ticket.payments.sum(:amount)
  end
  
  json.notes @notes
  json.warranty_until @repair_ticket.warranty_until&.iso8601
  
  json.footer do
    json.message "Thank you for your business!"
    json.printed_at Time.current.iso8601
    if @served_by
      json.served_by "#{@served_by.first_name} #{@served_by.last_name}"
    end
  end
end
