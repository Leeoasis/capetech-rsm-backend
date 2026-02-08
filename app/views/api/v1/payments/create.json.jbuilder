json.payment do
  json.partial! 'api/v1/payments/payment', payment: @payment
end

json.remaining_balance @remaining_balance
