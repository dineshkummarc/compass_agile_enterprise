class InvoicePaymentTerm < ActiveRecord::Base
  has_one    :invoice_payment_term_type
  belongs_to :invoice_payment_term_set
end
