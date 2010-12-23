class AddOpenIdAuthenticationTables < ActiveRecord::Migration
  def self.up
    create_table :open_id_auth_assoc, :force => true do |t|
      t.integer :issued, :lifetime
      t.string :handle, :assoc_type
      t.binary :server_url, :secret
    end

    create_table :open_id_auth_nonces, :force => true do |t|
      t.integer :timestamp, :null => false
      t.string :server_url, :null => true
      t.string :salt, :null => false
    end
  end

  def self.down
    drop_table :open_id_auth_assoc
    drop_table :open_id_auth_nonces
  end
end
