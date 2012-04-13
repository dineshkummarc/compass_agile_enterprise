class CreateMobileContainers
  
  def self.up
    User.all.each do |user|
      Mobile.create(:user => user)
    end
  end
  
  def self.down
    #remove data here
  end

end
