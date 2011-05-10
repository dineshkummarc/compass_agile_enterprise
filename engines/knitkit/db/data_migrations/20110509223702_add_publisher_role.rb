class AddPublisherRole
  
  def self.up
    if Role.iid('publisher').nil?
      Role.create(:internal_identifier => 'publisher', :description => 'Publisher')
    end
  end
  
  def self.down
    unless Role.iid('publisher').nil?
      Role.iid('publisher').destroy
    end
  end

end
