json.extract! payment, :id, :amount, :payment_method, :payment_date, :reference_number, :notes

json.created_at payment.created_at.iso8601

if payment.received_by
  json.received_by do
    json.id payment.received_by.id
    json.name "#{payment.received_by.first_name} #{payment.received_by.last_name}"
    json.email payment.received_by.email
  end
end

if payment.repair_ticket
  json.repair_ticket do
    json.id payment.repair_ticket.id
    json.ticket_number payment.repair_ticket.ticket_number
    json.status payment.repair_ticket.status
    json.estimated_cost payment.repair_ticket.estimated_cost
    json.final_cost payment.repair_ticket.final_cost
  end
end
