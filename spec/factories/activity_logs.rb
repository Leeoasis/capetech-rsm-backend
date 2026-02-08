FactoryBot.define do
  factory :activity_log do
    repair_ticket_id { 1 }
    user { nil }
    action_type { "MyString" }
    description { "MyText" }
    metadata { "" }
  end
end
