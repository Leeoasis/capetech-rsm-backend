json.activity_log do
  json.partial! 'api/v1/activity_logs/activity_log', activity_log: @activity_log
end
