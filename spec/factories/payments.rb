FactoryBot.define do
  factory :payment do
    repair_ticket { nil }
    amount { "9.99" }
    payment_method { 1 }
    payment_date { "2026-02-08 11:03:09" }
    reference_number { "MyString" }
    notes { "MyText" }
    received_by_user_id { 1 }
  end
end
