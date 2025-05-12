FactoryBot.define do
  factory :user do
    nickname { 'Daniel' }
    sequence :email do |n|
      "test#{n}@example.com"
    end
    password { '123456' }
    password_confirmation { '123456' }
  end
end
