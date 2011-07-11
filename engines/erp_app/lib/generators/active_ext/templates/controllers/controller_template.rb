class ErpApp::<%= container_class_name %>::<%= application_class_name %>::<%= class_name %>Controller < ErpApp::<%= container_class_name %>::<%= application_class_name %>::BaseController
  active_ext <%= class_name %> do |options|
    options[:inline_edit] = true
    options[:ignore_associations] = true
    options[:show_id] = true
    options[:show_timestamps] = true
    
    #additional options
    #options[:use_ext_forms] = false
    #options[:only] = [ {:internal_identifier => {:required => true, :readonly => false}}]
    options
  end

end


