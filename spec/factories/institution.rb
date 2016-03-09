FactoryGirl.define do
  sequence :city do |n|
    "By#{n}"
  end

  factory :institution do
    transient do
      city
    end
    name { "Universitetet i #{city}" }
    abbreviation { "Ui#{city}" }
    priority 1
  end
end
