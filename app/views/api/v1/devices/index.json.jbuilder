json.devices @devices do |device|
  json.partial! 'api/v1/devices/device', device: device
end

json.pagination do
  json.current_page @devices.current_page
  json.total_pages @devices.total_pages
  json.total_count @devices.total_count
  json.per_page @devices.limit_value
end
