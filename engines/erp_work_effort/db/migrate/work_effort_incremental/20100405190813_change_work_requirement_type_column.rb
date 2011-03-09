class ChangeWorkRequirementTypeColumn < ActiveRecord::Migration
  def self.up
    change_column :work_requirements, :type, :string
  end

  def self.down
    # A change_column will fail once any char data is saved in type column
    # doing a remove and add drops all data in type, must be done if we want
    # to go back. 
    remove_column :work_requirements, :type
    add_column    :work_requirements, :type, :integer
  end
end
