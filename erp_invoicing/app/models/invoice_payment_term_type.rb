class InvoicePaymentTermType < ActiveRecord::Base
  has_many :invoice_payment_terms
end
