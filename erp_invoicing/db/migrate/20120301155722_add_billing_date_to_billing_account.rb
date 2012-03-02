class AddBillingDateToBillingAccount < ActiveRecord::Migration
  def up
    unless columns(:billing_accounts).collect {|c| c.name}.include?('billing_date')
      add_column :billing_accounts, :billing_date, :date
    end
  end

  def down
    if columns(:billing_accounts).collect {|c| c.name}.include?('billing_date')
      remove_column :billing_accounts, :billing_date
    end
  end
end
