FactoryGirl.define do
  factory :nomination do
    institution
    name 'Navn Navnesen'
    reason 'En god grunn'
    nominator 'En venn'
    nominator_email 'venn@gmail.com'

    factory :approved_nomination do
      verified true
    end
  end
end
