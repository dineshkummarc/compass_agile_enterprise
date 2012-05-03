##
#The basic models, these factories have no
#callbacks, associations, sequences declared
#besides what's necessary
FactoryGirl.define do
  factory :payment_application
  factory :recurring_payment
  factory :billing_account
end
