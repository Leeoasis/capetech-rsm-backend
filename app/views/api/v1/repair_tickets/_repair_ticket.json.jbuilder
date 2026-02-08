json.extract! repair_ticket, :id, :ticket_number, :status, :priority, :issue_description, 
              :diagnosis, :repair_notes, :estimated_cost, :final_cost, :deposit_amount, 
              :warranty_until, :estimated_completion_date, :actual_completion_date

json.created_at repair_ticket.created_at.iso8601
json.updated_at repair_ticket.updated_at.iso8601

if repair_ticket.customer
  json.customer do
    json.id repair_ticket.customer.id
    json.name "#{repair_ticket.customer.first_name} #{repair_ticket.customer.last_name}"
    json.email repair_ticket.customer.email
    json.phone repair_ticket.customer.phone
  end
end

if repair_ticket.device
  json.device do
    json.id repair_ticket.device.id
    json.device_type repair_ticket.device.device_type
    json.brand repair_ticket.device.brand
    json.model repair_ticket.device.model
    json.serial_number repair_ticket.device.serial_number
  end
end

if repair_ticket.assigned_technician
  json.assigned_technician do
    json.id repair_ticket.assigned_technician.id
    json.name "#{repair_ticket.assigned_technician.first_name} #{repair_ticket.assigned_technician.last_name}"
    json.email repair_ticket.assigned_technician.email
  end
end
