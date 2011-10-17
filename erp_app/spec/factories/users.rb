FactoryGirl.define do

  factory :user do |u|
    u.login "admin"
    u.sequence(:email) { |n| "user#{n}@portablemind.com"}
    u.password "blash123"
    u.association :party_id, :factory => :party
  end
end
