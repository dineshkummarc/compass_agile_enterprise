class AttributeValue < ActiveRecord::Base
  belongs_to :attributed_record, :polymorphic => true
  belongs_to :attribute_type

  validates_format_of :value, :with => /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/, :if => :is_date?
  before_destroy :destroy_attribute_types_without_values

  def is_date?
    self.attribute_type.data_type == 'Date' ? true : false
  end

  def value_as_data_type
    data_type = self.attribute_type.data_type

    case data_type
    when "Date"
      self.value.to_date
    when "Boolean"
      self.value == "true" ? true : false
    when "Int"
      self.value.to_i
    when "Float"
      self.value.to_f
    else
      self.value
    end
  end

  def value_as_date
    if self.is_date?
      self.value.to_date
    else
      raise "value is not a Date or is not properly formated"
    end
  end

  def destroy_attribute_types_without_values
    self.attribute_type.destroy unless self.attribute_type.attribute_values.count > 1
  end
  
end