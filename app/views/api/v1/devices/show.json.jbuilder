json.device do
  json.partial! 'api/v1/devices/device', device: @device
  json.created_at @device.created_at.iso8601
  json.updated_at @device.updated_at.iso8601
  
  if @device.customer
    json.customer do
      json.extract! @device.customer, :id, :first_name, :last_name, :email, :phone
    end
  end
  
  json.repair_tickets_count @device.repair_tickets.count
end
