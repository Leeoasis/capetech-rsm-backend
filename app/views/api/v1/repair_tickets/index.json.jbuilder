json.repair_tickets @repair_tickets do |ticket|
  json.partial! 'api/v1/repair_tickets/repair_ticket_summary', repair_ticket: ticket
end

json.pagination do
  json.current_page @repair_tickets.current_page
  json.total_pages @repair_tickets.total_pages
  json.total_count @repair_tickets.total_count
  json.per_page @repair_tickets.limit_value
end

if @filters.present?
  json.filters @filters
end
