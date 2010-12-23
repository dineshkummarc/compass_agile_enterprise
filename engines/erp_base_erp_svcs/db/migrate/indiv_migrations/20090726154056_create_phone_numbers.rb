class CreatePhoneNumbers < ActiveRecord::Migration
  def self.up
    create_table :phone_numbers do |t|

			t.column    :phone_number,  		:string
			t.column    :description,       	:string

      t.timestamps

    end
  end

  def self.down
    drop_table :phone_numbers
  end
end
