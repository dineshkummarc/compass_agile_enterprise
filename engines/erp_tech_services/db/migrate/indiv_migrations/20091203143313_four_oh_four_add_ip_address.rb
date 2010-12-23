class FourOhFourAddIpAddress < ActiveRecord::Migration
  def self.up
    fofs = FourOhFour.find(:all)
    fofs.each do |fof|
      fof.destroy
    end

    add_column :four_oh_fours, :remote_address, :string
  end

  def self.down
    remove_column :four_oh_fours, :remote_address
  end
end
