class ContactPurpose < ActiveRecord::Base
    acts_as_nested_set
    include ErpTechSvcs::Utils::DefaultNestedSetMethods
    
    acts_as_erp_type
    
    has_and_belongs_to_many :contacts
end
