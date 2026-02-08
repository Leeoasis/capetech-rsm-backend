json.device do
  json.partial! 'api/v1/devices/device', device: @device
end
