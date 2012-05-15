class Payment < ActiveRecord::Base
  include AASM

  belongs_to :financial_txn, :dependent => :destroy
  has_many   :payment_gateways

  aasm_column :current_state

  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :declined
  aasm_state :authorized
  aasm_state :captured
  aasm_state :authorization_reversed
  aasm_state :canceled

  aasm_event :cancel do
    transitions :to => :canceled, :from => [:pending]
  end

  aasm_event :authorize do
      transitions :to => :authorized, :from => [:pending]
  end

  aasm_event :purchase do
      transitions :to => :captured, :from => [:authorized, :pending]
  end

  aasm_event :decline do
      transitions :to => :declined, :from => [:pending]
  end

  aasm_event :capture do
      transitions :to => :captured, :from => [:authorized, :pending]
  end

  aasm_event :reverse_authorization do
      transitions :to => :authorization_reversed, :from => [:authorized]
  end
end
