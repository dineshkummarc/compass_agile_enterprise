class CreateWebsitePartyRoles < ActiveRecord::Migration
  def up
    unless table_exists? :website_party_roles
      create_table :website_party_roles do |t|
        #foreign keys
        t.references :website
        t.references :role_type
        t.references :party

        t.timestamps
      end

      add_index :website_party_roles, :website_id
      add_index :website_party_roles, :role_type_id
      add_index :website_party_roles, :party_id
    end
  end

  def down
    unless table_exists? :website_party_roles
      drop_table :website_party_roles
    end
  end
end
