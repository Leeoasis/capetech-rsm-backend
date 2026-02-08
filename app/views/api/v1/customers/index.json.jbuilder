json.customers @customers do |customer|
  json.partial! 'api/v1/customers/customer', customer: customer
end

json.pagination do
  json.current_page @customers.current_page
  json.total_pages @customers.total_pages
  json.total_count @customers.total_count
  json.per_page @customers.limit_value
end
