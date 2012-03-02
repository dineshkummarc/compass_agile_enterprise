FinancialTxnAccount.class_eval do

	#This line of code connects the invoice to a polymorphic payment application.
	#The effect of this is to allow payments to be "applied_to" invoices
  has_many    :payment_applications, :as => :payment_applied_to
      
end