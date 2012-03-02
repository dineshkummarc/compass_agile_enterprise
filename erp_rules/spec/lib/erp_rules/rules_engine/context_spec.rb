require "spec_helper"

describe ErpRules::RulesEngine::Context do

  it "should add item and be able to retrieve it" do 

    subject[:test_val] = "test"

    subject[:test_val].should eq("test")
  end

  it "should handle float values correctly" do 

    subject[:test_val] = 179.5

    subject[:test_val].should eq(179.5)
  end

  it "should find a hash item as if it were a method on an object" do

    subject[:test_val] = "test"

    subject.test_val.should eq("test")
  end

  it "should set the value if the method name passed has an '='" do

    subject.send("test_val=", "test")

    subject.test_val.should eq("test")
  end

  it "should handle nested items" do

    subject[:test_key1] = {:test_key2 => "blah1",
                           :test_key3 => "blah2"}

    subject.test_key1.test_key2.should eq("blah1")
  end

  it "should convert all hashes to Context objects when initalized with a hash" do

    data = {:search_ctxt =>
            {:offer_ctxt =>
                {:valid_offers => [1,2],
                 :invalid_offers => [3]
                }
            }
    }

    ctx = ErpRules::RulesEngine::Context.new(data)

    ctx.search_ctxt.offer_ctxt.valid_offers.should include(1)
  end

  it "should covert hashes to Context obj's when set via method syntax" do

    subject.test_key1 = {:test_key2 => "blah1",
                           :test_key3 => "blah2"}

    subject.test_key1.test_key2.should eq("blah1")
  end

 end
