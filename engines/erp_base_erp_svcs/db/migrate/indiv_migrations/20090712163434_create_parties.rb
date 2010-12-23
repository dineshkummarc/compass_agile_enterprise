class CreateParties < ActiveRecord::Migration
  def self.up
    create_table :parties do |t|

      t.column    	:description,         :string
      t.column    	:business_party_id,   :integer
      t.column    	:business_party_type, :string
      t.column    	:list_view_image_id,  :integer
      
      #This field is here to provide a direct way to map CompassERP
      #business parties to unified idenfiers in organizations if they
      #have been implemented in an enterprise.
      t.column		:enterprise_identifier, :string

      t.timestamps

    end
  end

  def self.down
    drop_table :parties
  end
end
