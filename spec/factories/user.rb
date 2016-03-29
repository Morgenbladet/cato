FactoryGirl.define do
  sequence :mail do |n|
    "test_#{n}@leet.com"
  end

  factory :user do
    email { generate(:mail) }
    password "Password"
  end
end
