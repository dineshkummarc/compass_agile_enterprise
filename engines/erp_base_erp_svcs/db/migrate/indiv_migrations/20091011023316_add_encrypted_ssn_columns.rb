class AddEncryptedSsnColumns < ActiveRecord::Migration
  def self.up

    add_column :individuals, :encrypted_ssn, :string  	
    add_column :individuals, :temp_ssn, :string 
    add_column :individuals, :salt, :string       
  	
  end

  def self.down

    remove_column :individuals, :encrypted_ssn  	
    remove_column :individuals, :temp_ssn     
    remove_column :individuals, :salt       
  	
  end
end
