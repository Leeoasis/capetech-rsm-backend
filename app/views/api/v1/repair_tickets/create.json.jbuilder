json.repair_ticket do
  json.partial! 'api/v1/repair_tickets/repair_ticket', repair_ticket: @repair_ticket
end
