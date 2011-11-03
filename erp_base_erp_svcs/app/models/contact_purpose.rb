class ContactPurpose < ActiveRecord::Base
    acts_as_nested_set
    acts_as_erp_type
    
    has_and_belongs_to_many :contacts
end
