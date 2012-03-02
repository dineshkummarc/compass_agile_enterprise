class UpdateFinancialTxns < ActiveRecord::Migration
  def self.up
    if columns(:financial_txns).collect {|c| c.name}.include?('payment_type')
      remove_column :financial_txns, :payment_type
    end

    if columns(:financial_txns).collect {|c| c.name}.include?('amount_id')
      rename_column :financial_txns, :amount_id, :money_id
    end
  end

  def self.down
    unless columns(:financial_txns).collect {|c| c.name}.include?('payment_type')
      add_column :financial_txns, :payment_type, :string
    end

    if columns(:financial_txns).collect {|c| c.name}.include?('money_id')
      rename_column :financial_txns, :money_id, :amount_id
    end
  end
end
