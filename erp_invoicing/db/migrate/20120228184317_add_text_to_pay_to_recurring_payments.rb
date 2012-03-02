class AddTextToPayToRecurringPayments < ActiveRecord::Migration
  def up
    unless columns(:recurring_payments).collect {|c| c.name}.include?('text_to_pay')
      add_column :recurring_payments, :text_to_pay, :boolean
    end
  end

  def down
    if columns(:recurring_payments).collect {|c| c.name}.include?('text_to_pay')
      remove_column :recurring_payments, :text_to_pay
    end
  end
end
