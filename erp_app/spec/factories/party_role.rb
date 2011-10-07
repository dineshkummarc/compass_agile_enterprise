FactoryGirl.define do

  factory :party_role do |pr|
    pr.association :party, :factory => :party
    pr.association :role_type, :factory => :role_type
  end
end
