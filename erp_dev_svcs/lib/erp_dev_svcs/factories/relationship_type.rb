FactoryGirl.define do
  factory :relationship_type do |type|
    type.association :valid_from_role, :factory => :role_type
    type.association :valid_to_role, :factory => :role_type
    name "A relationship type"
    type.sequence(:internal_identifier){|n| "party relationship #{n}"}
  end
end
