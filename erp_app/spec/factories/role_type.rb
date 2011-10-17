FactoryGirl.define do

  factory :role_type do |role|
    role.sequence(:description){|n| "test role #{n}"}
    role.sequence(:internal_identifier){|n| "test_role_#{n}"}
    role.comments "A test role automatically created by Factory Girl"
  end
end
