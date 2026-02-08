json.repair_ticket do
  json.partial! 'api/v1/repair_tickets/repair_ticket', repair_ticket: @repair_ticket
  
  json.payments @repair_ticket.payments do |payment|
    json.extract! payment, :id, :amount, :payment_method, :payment_date, :reference_number
    json.created_at payment.created_at.iso8601
    
    if payment.received_by
      json.received_by do
        json.id payment.received_by.id
        json.name "#{payment.received_by.first_name} #{payment.received_by.last_name}"
      end
    end
  end
  
  json.total_paid @repair_ticket.payments.sum(:amount)
  json.balance_remaining (@repair_ticket.final_cost || @repair_ticket.estimated_cost || 0) - @repair_ticket.payments.sum(:amount)
  
  if @repair_ticket.repair_statuses.any?
    json.latest_status do
      latest = @repair_ticket.repair_statuses.order(created_at: :desc).first
      json.extract! latest, :id, :status, :notes
      json.created_at latest.created_at.iso8601
      
      if latest.changed_by
        json.changed_by do
          json.id latest.changed_by.id
          json.name "#{latest.changed_by.first_name} #{latest.changed_by.last_name}"
        end
      end
    end
  end
end
