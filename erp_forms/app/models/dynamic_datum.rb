class DynamicDatum < ActiveRecord::Base
  DYNAMIC_ATTRIBUTE_PREFIX = 'dyn_'
  
  has_dynamic_attributes :dynamic_attribute_prefix => DYNAMIC_ATTRIBUTE_PREFIX, :destroy_dynamic_attribute_for_nil => false

  belongs_to :reference, :polymorphic => true
  belongs_to :created_with_form, :class_name => "DynamicForm"
  belongs_to :updated_with_form, :class_name => "DynamicForm"
  belongs_to :created_by, :class_name => "User"
  belongs_to :updated_by, :class_name => "User"
  
  def dynamic_attributes_without_prefix
    attrs = {}
    self.dynamic_attributes.each do |k,v|
      attrs[k[DYNAMIC_ATTRIBUTE_PREFIX.length..(k.length)]] = v
    end

    attrs
  end
  
  def sorted_dynamic_attributes(with_prefix=true)    
    if !self.updated_with_form.nil?
      form = self.updated_with_form
    elsif !self.created_with_form.nil?
      form = self.created_with_form
    else
      form = nil
    end
    
    unless form.nil?
      if with_prefix
        keys = form.definition_object.collect{|f| DYNAMIC_ATTRIBUTE_PREFIX + f[:name]}
      else
        keys = form.definition_object.collect{|f| f[:name]}
      end

      sorted = []
      keys.each do |key|
        attribute = {}      
        if with_prefix
          attribute[key] = self.dynamic_attributes[key]
        else
          attribute[key] = self.dynamic_attributes_without_prefix[key]
        end
        
        sorted << attribute
      end
      
      return sorted
    else
      if with_prefix
        return self.dynamic_attributes
      else
        return self.dynamic_attributes_without_prefix
      end
    end
  end
  
end