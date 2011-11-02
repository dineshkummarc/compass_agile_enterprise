class CreateCompassAeInstance < ActiveRecord::Migration
  def self.up
    unless table_exists?(:compass_ae_instances)
      create_table :compass_ae_instances do |t|
        t.decimal :version
        
        t.timestamps
      end
    end
  end

  def self.down
    drop_table :compass_ae_instances
  end
end
