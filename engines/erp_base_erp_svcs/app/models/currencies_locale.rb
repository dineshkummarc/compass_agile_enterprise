class CurrenciesLocale < ActiveRecord::Base
  
  belongs_to :currency
  belongs_to :locale, :polymorphic => true
  
end
