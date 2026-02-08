json.repair_tickets @repair_tickets do |ticket|
  json.extract! ticket, :id, :ticket_number, :status, :issue_description, :estimated_cost, :final_cost
  json.created_at ticket.created_at.iso8601
  json.updated_at ticket.updated_at.iso8601
  
  if ticket.device
    json.device do
      json.id ticket.device.id
      json.device_type ticket.device.device_type
      json.brand ticket.device.brand
      json.model ticket.device.model
    end
  end
end

json.pagination do
  json.current_page @repair_tickets.current_page
  json.total_pages @repair_tickets.total_pages
  json.total_count @repair_tickets.total_count
  json.per_page @repair_tickets.limit_value
end
