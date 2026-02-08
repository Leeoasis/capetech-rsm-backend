FactoryBot.define do
  factory :repair_ticket do
    ticket_number { "MyString" }
    device { nil }
    customer { nil }
    assigned_technician_id { 1 }
    fault_description { "MyText" }
    accessories_received { "MyText" }
    estimated_cost { "9.99" }
    actual_cost { "9.99" }
    status { 1 }
    priority { 1 }
    completed_at { "2026-02-08 11:03:09" }
    collected_at { "2026-02-08 11:03:09" }
  end
end
