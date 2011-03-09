class CreateLoyaltyProgramCodes < ActiveRecord::Migration
  def self.up
    create_table :loyalty_program_codes do |t|
      t.string :identifier
      t.string :name
      t.string :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :loyalty_program_codes
  end
  # TODO add indexes
end
