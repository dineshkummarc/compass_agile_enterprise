require 'spec_helper'

describe AttributeType do
  it "can be instantiated" do
    AttributeType.new.should be_an_instance_of(AttributeType)
  end

  it "can be saved successfully" do
    new_attribute_type = AttributeType.create(:description => "Some description")
    new_attribute_type.should be_persisted
    new_attribute_type.internal_identifier.should eq("some_description")

  end

  describe "values_by_date_range" do
    it "should return all values attatched to AttributeType for the given date range" do
      attribute_type = AttributeType.new
      attribute_type.data_type = 'Date'
      attribute_type.description = 'Some Date Attribute'
      attribute_type.save

      in_range_value = AttributeValue.new
      in_range_value.value = "2011-12-15 00:00:00"
      attribute_type.attribute_values << in_range_value
      in_range_value.save

      out_of_range_value = AttributeValue.new
      out_of_range_value.value = "2011-12-31 00:00:00"
      attribute_type.attribute_values << out_of_range_value
      out_of_range_value.save
      
      start_date = Date.civil(2011, 12, 1)
      end_date = Date.civil(2011, 12, 30)

      date_range_values = attribute_type.values_by_date_range(start_date, end_date)

      date_range_values.should include(in_range_value)
    end
  end

  describe "find_by_iid_with_description" do
    it "should return an AttributeType object with the given description" do
      attribute_type = AttributeType.create(:description => "Some Description")
      found_attribute_type = AttributeType.find_by_iid_with_description("some description")
      found_attribute_type.should eq(attribute_type)
    end
  end

  describe "update_iid" do
    it "should set the iid to a snake case version of the description when a new attribute type is created" do
      attribute_type = AttributeType.create(:description => " Some attribute type ", :data_type => "text")
      attribute_type.internal_identifier.should eq("some_attribute_type")
    end
  end
end