FactoryBot.define do
    factory :user do
        sequence(:name) { "example_user" }
        sequence(:email) { "example@example.com" }
        sequence(:password) { "foobar" }
        sequence(:password_confirmation) { "foobar" }
    end
end