class DynamicFormDocument < ActiveRecord::Base
  belongs_to :dynamic_form_model

  has_dynamic_forms
	has_dynamic_data

  # declare a subclass
  # pass in name of subclass
  def self.declare(klass_name)    
    Object.send(:remove_const, klass_name) if Object.const_defined?(klass_name) and !Rails.configuration.cache_classes
    Object.const_set(klass_name, Class.new(DynamicFormDocument)) unless Object.const_defined?(klass_name)
  end

  def send_email
    WebsiteInquiryMailer.deliver_inquiry(self)
  end
  
  def self.class_exists?(class_name)
    klass = Module.const_get(class_name)
    if klass.is_a?(Class)
      if klass.superclass == ActiveRecord::Base or klass.superclass == DynamicModel
        return true
      else
        return false
      end
    else
      return false
    end
  rescue NameError
    return false
  end

end