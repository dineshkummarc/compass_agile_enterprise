FactoryGirl.define do
  factory :party_relationship do |pr|
    pr.description "A Party Relationship"
    pr.association :from_party, :factory => :party
    pr.association :to_party, :factory => :party
    pr.association :from_role, :factory => :role_type
    pr.association :to_role, :factory => :role_type
    pr.association :relationship_type, :factory => :relationship_type
  end
end
