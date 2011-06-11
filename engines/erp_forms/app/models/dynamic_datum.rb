class DynamicDatum < ActiveRecord::Base
  DYNAMIC_ATTRIBUTE_PREFIX = 'dyn_'
  
  has_dynamic_attributes :dynamic_attribute_prefix => DYNAMIC_ATTRIBUTE_PREFIX, :destroy_dynamic_attribute_for_nil => false

  belongs_to :reference, :polymorphic => true
  belongs_to :created_with_form, :class_name => "DynamicForm"
  belongs_to :updated_with_form, :class_name => "DynamicForm"
  
  def sorted_dynamic_attributes
    if !self.updated_with_form.nil?
      form = self.updated_with_form
    elsif !self.created_with_form.nil?
      form = self.created_with_form
    else
      form = nil
    end
    
    unless form.nil?
      keys = form.definition_object.collect{|f| DYNAMIC_ATTRIBUTE_PREFIX + f['name']}

      sorted = []
      keys.each do |key|
        attribute = {}      
        attribute[key] = self.dynamic_attributes[key]
        sorted << attribute
      end
      
      return sorted
    else
      return self.dynamic_attributes
    end
  end
  
end