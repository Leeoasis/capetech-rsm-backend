json.payment do
  json.partial! 'api/v1/payments/payment', payment: @payment
end

json.ticket do
  json.id @repair_ticket.id
  json.ticket_number @repair_ticket.ticket_number
  json.status @repair_ticket.status
  json.total_cost @repair_ticket.final_cost || @repair_ticket.estimated_cost
  json.total_paid @total_paid
  json.balance_remaining @balance_remaining
end

json.message @message
