class DynamicFormModel < ActiveRecord::Base
  has_many :dynamic_form_documents
  has_many :dynamic_forms, :dependent => :destroy

  def self.get_constant(klass_name)
    begin
      return klass_name.constantize
    rescue
      DynamicFormDocument.declare(klass_name)
      return klass_name.constantize
    end
  end

  def self.get_instance(klass_name)
    DynamicFormModel.get_constant(klass_name).new
  end

  # handles both static and dynamic attributes
  def self.save_all_attributes(dynamicObject, params, ignored_params=[])
    
    params.each do |k,v|
      unless ignored_params.include?(k.to_s) or k == '' or k == '_'
        if dynamicObject.attributes.include?(k)
          dynamicObject.send(k + '=', v) 
        else
          if ['created_by','updated_by','created_at','updated_at','created_with_form_id','updated_with_form_id'].include?(k)
            key = k + '='
          else
            key = DynamicDatum::DYNAMIC_ATTRIBUTE_PREFIX + k + '='
          end
          
          dynamicObject.data.send(key, v) 
        end
      end
    end
    
    if dynamicObject.valid? and dynamicObject.save        
      return dynamicObject
    else
      return false
    end
  end

end