class BankAccountType < ActiveRecord::Base
  has_many :bank_accounts
end
