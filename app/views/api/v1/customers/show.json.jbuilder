json.customer do
  json.partial! 'api/v1/customers/customer', customer: @customer
  json.devices_count @customer.devices.count
  json.repair_tickets_count @customer.repair_tickets.count
end
