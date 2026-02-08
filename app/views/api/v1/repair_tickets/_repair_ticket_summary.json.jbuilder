json.extract! repair_ticket, :id, :ticket_number, :status, :priority, :issue_description, 
              :estimated_cost, :final_cost

json.created_at repair_ticket.created_at.iso8601

if repair_ticket.customer
  json.customer do
    json.id repair_ticket.customer.id
    json.name "#{repair_ticket.customer.first_name} #{repair_ticket.customer.last_name}"
  end
end

if repair_ticket.device
  json.device do
    json.id repair_ticket.device.id
    json.device_type repair_ticket.device.device_type
    json.brand repair_ticket.device.brand
    json.model repair_ticket.device.model
  end
end
