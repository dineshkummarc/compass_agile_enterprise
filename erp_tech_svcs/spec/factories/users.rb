FactoryGirl.define do

  factory :user do |u|
    #u.login "admin"
    u.sequence(:username) { |n| "admin#{n}"}
    u.sequence(:email) { |n| "user#{n}@portablemind.com"}
    u.association :party, :factory => :party
  end
end
