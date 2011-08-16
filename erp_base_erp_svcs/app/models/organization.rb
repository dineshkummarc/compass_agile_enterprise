class Organization < ActiveRecord::Base
    has_one :party, :as => :business_party
 
    def to_label
        "#{description}"
    end
end
