json.devices @devices do |device|
  json.extract! device, :id, :device_type, :brand, :model, :serial_number, :imei, :notes
  json.created_at device.created_at.iso8601
end

json.pagination do
  json.current_page @devices.current_page
  json.total_pages @devices.total_pages
  json.total_count @devices.total_count
  json.per_page @devices.limit_value
end
