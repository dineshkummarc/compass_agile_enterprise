require "spec_helper"

describe ErpRules::RulesEngine::Ruleby::Engine do

  before(:each) do

    RuleBook = Class.new(Ruleby::Rulebook) do
      def rules
        rule :last_name_is_smith, {:priority => 1},[ErpRules::RulesEngine::Context, :context, m.customer_last_name == 'Smith'] do |v|
          v[:context].valid_offers << 2
        end
      end
    end
    @rule_context = ErpRules::RulesEngine::Context.new
  end

  it "should invoke ruleby and execute context against a rulebook" do
    @rule_context[:customer_last_name] = "Smith"
    @rule_context[:valid_offers] = []

    @context = ErpRules::RulesEngine::Ruleby::Engine.invoke(RuleBook, @rule_context)
    @context[:valid_offers].should include(2)
  end


end
