class Organization < ActiveRecord::Base

    has_one :party, :as => :business_party

    def after_create
 
        pty = Party.new
        pty.description = self.description
        pty.business_party = self
    
        pty.save
        self.save

    end
     def after_save
     self.party.description = self.description
     self.party.save
  end

    def after_destroy
        if self.party
            self.party.destroy
        end
    end
 
    def to_label
        "#{description}"
    end

end
