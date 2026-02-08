FactoryBot.define do
  factory :device do
    customer { nil }
    device_type { 1 }
    brand { "MyString" }
    model { "MyString" }
    serial_number { "MyString" }
    imei { "MyString" }
    password_pin { "MyString" }
    notes { "MyText" }
    deleted_at { "2026-02-08 11:03:03" }
  end
end
