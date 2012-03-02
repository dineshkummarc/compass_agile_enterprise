require 'spec_helper'

describe Category do
  it "can be instantiated" do
    Category.new.should be_an_instance_of(Category)
  end

  it "can be saved successfully" do
    Category.create.should be_persisted
  end
  
  it "can be found by iid" do
    Category.create(:internal_identifier => 'my_category')
    category = Category.iid('my_category')
    category.should be_an_instance_of(Category)
    category.internal_identifier.should == 'my_category'
  end
end