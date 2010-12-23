class CreateIndividuals < ActiveRecord::Migration
  def self.up
    create_table :individuals do |t|

		t.column  :party_id, :integer
		t.column  :current_last_name, :string
		t.column  :current_first_name, :string
		t.column  :current_middle_name, :string
		t.column  :current_personal_title, :string
		t.column  :current_suffix, :string
		t.column  :current_nickname, :string
		t.column  :gender, :string, :limit => 1
		t.column  :birth_date, :date
		t.column  :height, :decimal, :precision => 5, :scale => 2
		t.column  :weight, :integer
		t.column  :mothers_maiden_name, :string
		t.column  :marital_status, :string, :limit => 1
		t.column  :social_security_number, :string
		t.column  :current_passport_number, :integer
		t.column  :current_passport_expire_date, :date
		t.column  :total_years_work_experience, :integer
		t.column  :comments, :string
	
		t.timestamps

    end
  end

  def self.down
    drop_table :individuals
  end
end
