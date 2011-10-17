FactoryGirl.define do

  factory :user do |u|
    #u.login "admin"
    u.username "admin"
    u.sequence(:email) { |n| "user#{n}@portablemind.com"}
    u.password "blash123"
    u.association :party, :factory => :party
  end
end
