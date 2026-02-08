json.message "Status updated successfully"

json.repair_ticket do
  json.partial! 'api/v1/repair_tickets/repair_ticket', repair_ticket: @repair_ticket
  
  if @repair_ticket.repair_statuses.any?
    json.latest_status do
      latest = @repair_ticket.repair_statuses.order(created_at: :desc).first
      json.extract! latest, :id, :status, :notes
      json.created_at latest.created_at.iso8601
      
      if latest.changed_by
        json.changed_by do
          json.id latest.changed_by.id
          json.name "#{latest.changed_by.first_name} #{latest.changed_by.last_name}"
        end
      end
    end
  end
end
