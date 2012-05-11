class AttributeType < ActiveRecord::Base
  has_many :attribute_values, :dependent => :destroy

  validates_uniqueness_of :internal_identifier
  validates :description, :presence => true

  before_save :update_iid

  def values_by_date_range(start_date, end_date)
    raise "attribute_type does not have a data_type of Date" unless self.data_type == "Date"
    
    attribute_values = self.attribute_values
    attribute_values.each do |attribute_value|
      unless attribute_value.value_as_date >= start_date and attribute_value.value_as_date <= end_date
        attribute_values.delete(attribute_value)
      end
    end

    attribute_values
  end

  def self.find_by_iid_with_description(description)
    iid = description.strip.underscore.gsub(/\s+/,"_")
    AttributeType.find_by_internal_identifier iid
  end

  def update_iid
    self.internal_identifier = self.description.strip.underscore.gsub(/\s+/,"_")
  end
end