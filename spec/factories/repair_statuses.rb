FactoryBot.define do
  factory :repair_status do
    repair_ticket { nil }
    status { 1 }
    notes { "MyText" }
    changed_by_user_id { 1 }
  end
end
