class CreatePartyRoles < ActiveRecord::Migration
  def self.up
    create_table :party_roles do |t|

        #this column holds the class name of the 
        #subtype of party-to-role_type relatsionship
        t.column  :type, :string
        #xref between party and role_type      
        t.column  :party_id, :integer
    	t.column  :role_type_id, :integer

    	t.timestamps

    end
  end

  def self.down
    drop_table :party_roles
  end
end
