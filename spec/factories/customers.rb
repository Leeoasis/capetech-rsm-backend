FactoryBot.define do
  factory :customer do
    first_name { "MyString" }
    last_name { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    address { "MyText" }
    id_number { "MyString" }
    active { false }
    deleted_at { "2026-02-08 11:03:03" }
  end
end
