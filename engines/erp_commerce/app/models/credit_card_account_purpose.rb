class CreditCardAccountPurpose < ActiveRecord::Base
    acts_as_nested_set
    include TechServices::Utils::DefaultNestedSetMethods

    has_many :credit_card_accounts

end
