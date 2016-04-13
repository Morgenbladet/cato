FactoryGirl.define do
  factory :nomination do
    institution
    name 'Navn Navnesen'

    trait :approved do
      after(:create) do |nom, evaluator|
        create(:reason, nomination: nom, verified: true)
      end
    end

    factory :nomination_with_reasons do
      transient do
        reasons_count 3
        verified false
      end

      after(:create) do |nom, evaluator|
        create_list(:reason, evaluator.reasons_count,
                    nomination: nom, verified: evaluator.verified)
      end
    end
  end
end
