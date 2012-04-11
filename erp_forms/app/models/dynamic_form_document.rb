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
    begin
      WebsiteInquiryMailer.inquiry(self).deliver
    rescue Exception => e
      system_user = Party.find_by_description('Compass AE')
      AuditLog.custom_application_log_message(system_user, e)
    end
  end
  
  def self.class_exists?(class_name)
	result = nil
	begin
	  klass = Module.const_get(class_name)
      result = klass.is_a?(Class) ? ((klass.superclass == ActiveRecord::Base or klass.superclass == DynamicModel) ? true : nil) : nil
	rescue NameError
	  result = nil
	end
	result
  end

end