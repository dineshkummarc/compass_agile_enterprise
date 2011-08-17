require 'has_many_polymorphic'
require 'attr_encrypted'
require 'awesome_nested_set'
require 'will_paginate'

module ErpBaseErpSvcs
  class Engine < Rails::Engine
    isolate_namespace ErpBaseErpSvcs
	
	  ActiveSupport.on_load(:active_record) do
      include ErpBaseErpSvcs::Extensions::ActiveRecord::IsDescribable
      include ErpBaseErpSvcs::Extensions::ActiveRecord::HasNotes
	    include ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsErpType
      include ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsCategory
      include ErpBaseErpSvcs::Extensions::ActiveRecord::HasContact
    end
    
  end
end
