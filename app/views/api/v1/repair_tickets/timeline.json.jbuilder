json.repair_statuses @repair_ticket.repair_statuses.order(created_at: :desc) do |status|
  json.extract! status, :id, :status, :notes
  json.created_at status.created_at.iso8601
  
  if status.changed_by
    json.changed_by do
      json.id status.changed_by.id
      json.name "#{status.changed_by.first_name} #{status.changed_by.last_name}"
    end
  end
end

json.activity_logs @repair_ticket.activity_logs.order(created_at: :desc) do |log|
  json.extract! log, :id, :action_type, :description, :metadata
  json.created_at log.created_at.iso8601
  
  if log.user
    json.user do
      json.id log.user.id
      json.name "#{log.user.first_name} #{log.user.last_name}"
    end
  end
end
