class CreateSecurityQuestions < ActiveRecord::Migration
  def self.up
    create_table :security_questions do |t|

      t.string :question


      t.timestamps

    end
  end

  def self.down
    drop_table :security_questions
  end
end
