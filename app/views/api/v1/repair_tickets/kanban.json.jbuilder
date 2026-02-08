json.kanban do
  json.pending do
    json.tickets @grouped_tickets['pending'] || [] do |ticket|
      json.partial! 'api/v1/repair_tickets/repair_ticket_summary', repair_ticket: ticket
    end
    json.count (@grouped_tickets['pending'] || []).size
  end
  
  json.in_progress do
    json.tickets @grouped_tickets['in_progress'] || [] do |ticket|
      json.partial! 'api/v1/repair_tickets/repair_ticket_summary', repair_ticket: ticket
    end
    json.count (@grouped_tickets['in_progress'] || []).size
  end
  
  json.awaiting_parts do
    json.tickets @grouped_tickets['awaiting_parts'] || [] do |ticket|
      json.partial! 'api/v1/repair_tickets/repair_ticket_summary', repair_ticket: ticket
    end
    json.count (@grouped_tickets['awaiting_parts'] || []).size
  end
  
  json.ready_for_pickup do
    json.tickets @grouped_tickets['ready_for_pickup'] || [] do |ticket|
      json.partial! 'api/v1/repair_tickets/repair_ticket_summary', repair_ticket: ticket
    end
    json.count (@grouped_tickets['ready_for_pickup'] || []).size
  end
  
  json.completed do
    json.tickets @grouped_tickets['completed'] || [] do |ticket|
      json.partial! 'api/v1/repair_tickets/repair_ticket_summary', repair_ticket: ticket
    end
    json.count (@grouped_tickets['completed'] || []).size
  end
  
  json.cancelled do
    json.tickets @grouped_tickets['cancelled'] || [] do |ticket|
      json.partial! 'api/v1/repair_tickets/repair_ticket_summary', repair_ticket: ticket
    end
    json.count (@grouped_tickets['cancelled'] || []).size
  end
end

json.stats do
  json.total_tickets @stats[:total_tickets] || 0
  json.pending_count @stats[:pending_count] || 0
  json.in_progress_count @stats[:in_progress_count] || 0
  json.completed_today @stats[:completed_today] || 0
  json.total_revenue @stats[:total_revenue] || 0
end
