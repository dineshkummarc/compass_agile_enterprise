class RecurringPayment < ActiveRecord::Base
  belongs_to :billing_account
  belongs_to :payment_account, :polymorphic => true

  def schedule_payment(date)
    unless self.payment_account.nil?
      if self.billing_account.has_outstanding_balance?
        payment_amount = self.billing_account.outstanding_balance
        if payment_amount < self.pay_up_to_amount

          money = Money.create(
            :amount => payment_amount.to_f,
            :description => "AutoPayment",
            :currency => Currency.usd
          )
          financial_txn = FinancialTxn.create(
            :apply_date => date,
            :money => money
          )
          financial_txn.description = "AutoPayment"
          financial_txn.account = self.payment_account.account_root
          financial_txn.save

          PaymentApplication.create(
            :financial_txn => financial_txn,
            :payment_applied_to => self.billing_account,
            :money => money,
            :comment => "AutoPayment"
          )

          #make sure the payment is below the pay_up_to_amount
        else
          #notify payment greater than amount in autopay
        end
      end#make sure the account has an outstanding balance
    end#make sure it has a payment account
    
  end

end