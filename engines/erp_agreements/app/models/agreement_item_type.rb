class AgreementItemType < ActiveRecord::Base
  acts_as_nested_set
  include TechServices::Utils::DefaultNestedSetMethods

  AgreementItemType.include_root_in_json = false if AgreementItemType.respond_to?(:include_root_in_json)
    
  

end
