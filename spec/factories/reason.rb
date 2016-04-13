FactoryGirl.define do
  factory :reason do
    nomination
    reason 'En god grunn'
    nominator 'En venn'
    nominator_email 'venn@gmail.com'

    factory :verified_reason do
      verified true
    end
  end
end
