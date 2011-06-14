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

  #get all file in root app/models, first level plugins app/models & extensions
  def self.models_with_dynamic_data
    model_names = []
    base_models = Dir.glob("#{RAILS_ROOT}/app/models/*.rb")
    plugin_models = Dir.glob("#{RAILS_ROOT}/vendor/plugins/*/app/models/*.rb")
    extensions = Dir.glob("#{RAILS_ROOT}/vendor/plugins/*/app/models/extensions/*.rb")
    widget_models = Dir.glob("#{RAILS_ROOT}/vendor/plugins/*/lib/erp_app/widgets/*/models/*.rb")
    files = base_models + plugin_models + extensions + widget_models
    
    files.each do |filename|
      next if filename =~ /#{['svn','git'].join("|")}/
      open(filename) do |file|
        if file.grep(/has_dynamic_data/).any?
          model = File.basename(filename).gsub(".rb", "").camelize
          if DynamicFormDocument.class_exists?(model)
            model_names << model
          end
        end
      end
    end
    
    model_names.delete('DynamicDatum')
    model_names.delete('DynamicFormDocument')

    model_names
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