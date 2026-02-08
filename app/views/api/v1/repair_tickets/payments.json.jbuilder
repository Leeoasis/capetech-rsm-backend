json.payments @payments do |payment|
  json.extract! payment, :id, :amount, :payment_method, :payment_date, :reference_number, :notes
  json.created_at payment.created_at.iso8601
  
  if payment.received_by
    json.received_by do
      json.id payment.received_by.id
      json.name "#{payment.received_by.first_name} #{payment.received_by.last_name}"
    end
  end
end

json.total_paid @payments.sum(:amount)
json.balance_remaining (@repair_ticket.final_cost || @repair_ticket.estimated_cost || 0) - @payments.sum(:amount)
