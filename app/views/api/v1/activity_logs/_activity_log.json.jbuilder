json.extract! activity_log, :id, :action_type, :description, :metadata

json.created_at activity_log.created_at.iso8601

if activity_log.user
  json.user do
    json.id activity_log.user.id
    json.name "#{activity_log.user.first_name} #{activity_log.user.last_name}"
    json.email activity_log.user.email
  end
end

if activity_log.repair_ticket
  json.repair_ticket do
    json.id activity_log.repair_ticket.id
    json.ticket_number activity_log.repair_ticket.ticket_number
    json.status activity_log.repair_ticket.status
  end
end
