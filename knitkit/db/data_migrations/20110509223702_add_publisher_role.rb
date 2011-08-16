class AddPublisherRole
  
  def self.up
    Role.create(:internal_identifier => 'publisher', :description => 'Publisher')
  end
  
  def self.down
    Role.iid('publisher').destroy
  end

end
