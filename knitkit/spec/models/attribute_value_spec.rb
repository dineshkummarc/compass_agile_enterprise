require 'spec_helper'

describe AttributeValue do
  it "can be instantiated" do
    AttributeValue.new.should be_an_instance_of(AttributeValue)
  end

  it "can be saved successfully" do
    attribute_type = AttributeType.create(:description => "Some Desc", :data_type => "Text")
    attribute_value = AttributeValue.new
    attribute_type.attribute_values << attribute_value
    attribute_value.save

    attribute_value.should be_persisted
  end

  it "should destroy attatched AttributeType when a value is deleted if that is the last value connected to the AttributeType" do
    attribute_type = AttributeType.create(:description => "Some Desc", :data_type => "Text")
    attribute_value = AttributeValue.new
    attribute_type.attribute_values << attribute_value
    attribute_value.save

    AttributeType.find_by_description("Some Desc").should eq(attribute_type)
    attribute_value.destroy
    AttributeType.find_by_description("Some Desc").should eq(nil)
  end

  describe "is_date?" do
    it "should return true if the AttributeValue's AttributeType has a data_type of 'Date'" do
      attribute_type = AttributeType.create(:description => "Some Date Attribute", :data_type => "Date")
      attribute_value = AttributeValue.new
      attribute_value.value = "12/12/2011"
      attribute_type.attribute_values << attribute_value
      attribute_value.save

      attribute_value.is_date?.should eq(true)
    end

    it "should return false if the AttributeValue's AttributeType has a data_type not equal to 'Date'" do
      attribute_type = AttributeType.create(:description => "Some Text Attribute", :data_type => "Text")
      attribute_value = AttributeValue.new
      attribute_value.value = "some text"
      attribute_type.attribute_values << attribute_value
      attribute_value.save

      attribute_value.is_date?.should eq(false)
    end
  end

  describe "value_as_date" do
    it "should return a date object equivilant to the AttributeValue's value" do
      attribute_type = AttributeType.create(:description => "Some Date Attribute", :data_type => "Date")
      attribute_value = AttributeValue.new
      attribute_value.value = "2011-12-01 00:00:00"
      attribute_type.attribute_values << attribute_value
      attribute_value.save

      date = Date.civil(2011, 12, 1)
      attribute_value.value_as_date.should eq(date)
    end
  end

  describe "value_as_data_type" do
    it "should return a date if the associated attribute_types data_type is 'Date'" do
      attribute_type = AttributeType.create(:description => "Some Date Attribute", :data_type => "Date")
      attribute_value = AttributeValue.new
      attribute_value.value = "2011-12-01 00:00:00"
      attribute_type.attribute_values << attribute_value
      attribute_value.save

      attribute_value.value_as_data_type.should be_kind_of(Date)
    end

    it "should return a string if the associated attribute_types data_type is 'String'" do
      attribute_type = AttributeType.create(:description => "Some String Attribute", :data_type => "String")
      attribute_value = AttributeValue.new
      attribute_value.value = "some string"
      attribute_type.attribute_values << attribute_value
      attribute_value.save

      attribute_value.value_as_data_type.should be_kind_of(String)
    end

    it "should return a boolean if the associated attribute_types data_type is 'Boolean'" do
      attribute_type = AttributeType.create(:description => "Some Boolean Attribute", :data_type => "Boolean")
      attribute_value = AttributeValue.new
      attribute_value.value = "true"
      attribute_type.attribute_values << attribute_value
      attribute_value.save

      attribute_value.value_as_data_type.should eq(true)
    end

    it "should return a integer if the associated attribute_types data_type is 'Int'" do
      attribute_type = AttributeType.create(:description => "Some Integer Attribute", :data_type => "Int")
      attribute_value = AttributeValue.new
      attribute_value.value = "1"
      attribute_type.attribute_values << attribute_value
      attribute_value.save

      attribute_value.value_as_data_type.should be_kind_of(Integer)
    end

    it "should return a float if the associated attribute_types data_type is 'Float'" do
      attribute_type = AttributeType.create(:description => "Some Float Attribute", :data_type => "Float")
      attribute_value = AttributeValue.new
      attribute_value.value = "1.1"
      attribute_type.attribute_values << attribute_value
      attribute_value.save

      attribute_value.value_as_data_type.should be_kind_of(Float)
    end
  end
end