class RecurringPayment < ActiveRecord::Base
  belongs_to :billing_account
  belongs_to :payment_account, :polymorphic => true
end