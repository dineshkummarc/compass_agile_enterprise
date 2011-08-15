class CurrenciesLocale < ActiveRecord::Base
  
  belongs_to :currency, :class_name => 'ErpBaseErpSvcs::Currency'
  belongs_to :locale, :polymorphic => true
  
end
