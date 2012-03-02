class AddApplyDateToFinancialTxn < ActiveRecord::Migration
  def change
    unless columns(:financial_txns).collect {|c| c.name}.include?('apply_date')
      add_column :financial_txns, :apply_date, :date
    end
  end
end
