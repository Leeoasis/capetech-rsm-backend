json.activity_logs @activity_logs do |log|
  json.partial! 'api/v1/activity_logs/activity_log', activity_log: log
end

json.pagination do
  json.current_page @activity_logs.current_page
  json.total_pages @activity_logs.total_pages
  json.total_count @activity_logs.total_count
  json.per_page @activity_logs.limit_value
end
