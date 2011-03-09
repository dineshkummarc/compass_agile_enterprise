class CreateBizTxnRelationships < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_relationships do |t|

      t.column  :biz_txn_rel_type_id, :integer
      t.column  :description, :string 
      
      t.column  :txn_event_id_from, :integer
      t.column  :txn_event_id_to, :integer
      
      t.column  :status_type_id, :integer
      t.column  :from_date, :date
      t.column  :thru_date, :date 

      t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_relationships
  end
end
