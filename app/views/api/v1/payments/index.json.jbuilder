json.payments @payments do |payment|
  json.partial! 'api/v1/payments/payment', payment: payment
end

json.pagination do
  json.current_page @payments.current_page
  json.total_pages @payments.total_pages
  json.total_count @payments.total_count
  json.per_page @payments.limit_value
end
