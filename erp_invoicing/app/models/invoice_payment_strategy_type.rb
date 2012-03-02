class InvoicePaymentStrategyType < ActiveRecord::Base
  acts_as_erp_type

  has_many :invoices
end
