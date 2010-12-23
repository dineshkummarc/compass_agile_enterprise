class CreateEntityContentAssignments < ActiveRecord::Migration
  def self.up
    create_table :entity_content_assignments do |t|

      t.column    :content_mgt_asset_id,      :integer      
      t.column    :da_assignment_id,          :integer
      t.column    :da_assignment_type,        :string
      t.column    :default_list_image_flag,   :integer
      t.column    :description,               :string

      t.timestamps
    end
  end

  def self.down
    drop_table :entity_content_assignments
  end
end
