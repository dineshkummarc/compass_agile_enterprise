class CreditCardAccountPartyRole < ActiveRecord::Base
  belongs_to :credit_card_account
  belongs_to :role_type
  belongs_to :party
  belongs_to :credit_card
end