require "spec_helper"

describe ErpRules::Extensions::ActiveRecord::ActsAsBusinessRule do

  before(:each) do
    TestClass = Class.new(ActiveRecord::Base) do 
      acts_as_business_rule
      set_table_name "role_types"
    end
  end

  it "should provide an is_match? method to an ActiveRecord::Base class" do
    @test_obj = TestClass.new
    @test_obj.respond_to?(:is_match?).should eq(true)
  end

  it "should provide a get_matches! method as a singleton" do
    TestClass.respond_to?(:get_matches!).should eq(true)
  end
end
