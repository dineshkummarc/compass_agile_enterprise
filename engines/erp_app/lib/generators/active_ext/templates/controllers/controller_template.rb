class ErpApp::<%= container_class_name %>::<%= application_class_name %>::<%= class_name %>Controller < ErpApp::<%= container_class_name %>::<%= application_class_name %>::BaseController
  active_ext <%= class_name %> do |options|
    options[:inline_edit] = true
    options[:show_id] = true
    options[:show_timestamps] = true
    options
  end

end


