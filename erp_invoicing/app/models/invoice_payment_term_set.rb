class InvoicePaymentTermSet < ActiveRecord::Base
  belongs_to :invoice
  has_many   :invoice_payment_terms

  alias :payment_terms :invoice_payment_terms
end
