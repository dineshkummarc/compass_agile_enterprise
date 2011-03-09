class ReservationModelsCatchup < ActiveRecord::Migration
  def self.up
    add_column		:order_txns, :order_txn_record_id,    	:integer
		add_column		:order_txns, :order_txn_record_type,  	:string
  end

  def self.down
    remove_column		:order_txns, :order_txn_record_id
		remove_column		:order_txns, :order_txn_record_type
  end
end
