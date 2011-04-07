class CreateTenantsTable < ActiveRecord::Migration
  def self.up
    unless table_exists?(:tenants)
      create_table :tenants do |t|
        t.string :schema
        
    	  t.timestamps
      end
    end

    unless table_exists?(:domains)
      create_table :domains do |t|
        t.string :host
        t.string :route
        t.references :tenant

    	  t.timestamps
      end

      add_index :domains, :tenant_id
    end
  end

  def self.down
    if table_exists?(:tenants)
      drop_table :tenants
    end

    if table_exists?(:domains)
      drop_table :domains
    end
  end
end
