json.extract! device, :id, :device_type, :brand, :model, :serial_number, :imei, :notes

if device.customer
  json.customer do
    json.id device.customer.id
    json.name "#{device.customer.first_name} #{device.customer.last_name}"
  end
end
