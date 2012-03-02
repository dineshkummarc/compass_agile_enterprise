require "spec_helper"

describe ErpRules::Extensions::ActiveRecord::HasRuleContext do

  before(:each) do
    TestClass = Class.new(ActiveRecord::Base) do 
      has_rule_context
      set_table_name "role_types"
    end
  end

  it "should provide a get_context method to an ActiveRecord::Base class" do

    @test_obj = TestClass.new
    @test_obj.respond_to?(:get_context).should eq(true)
  end

  it "should return a hash with the attributes of the model" do

    @obj = TestClass.new
    @obj.internal_identifier = "test_obj"
    @obj.save

    @result = @obj.get_context()
    @result.has_key?("internal_identifier").should eq(true)
    @result["internal_identifier"].should eq("test_obj")
  end

end
