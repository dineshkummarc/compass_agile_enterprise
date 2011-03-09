class CreateGlAccounts < ActiveRecord::Migration
  def self.up
    create_table :gl_accounts do |t|

      #these columns are required to support the behavior of the plugin 'better_nested_set'

      t.column  	:parent_id,    :integer
      t.column  	:lft,          :integer
      t.column  	:rgt,          :integer

      #custom columns go here   

      t.column  	:description, :string
      t.column  	:comments, :string

  		t.column 	  :internal_identifier, 	:string

  		t.column 	  :external_identifier, 	:string
  		t.column 	  :external_id_source, 	:string

      t.timestamps
      
    end
  end

  def self.down
    drop_table :gl_accounts
  end
end
