require "spec_helper"

describe ErpRules::RulesEngine::RulesFacade do

  before(:each) do
    #ErpRules::RulesEngine::Ruleby::Engine

    RuleBook = Class.new(Ruleby::Rulebook) do
      def rules
        rule :last_name_is_smith, {:priority => 1},[ErpRules::RulesEngine::Context, :context, m.customer_last_name == 'Smith'] do |v|
          v[:context].valid_offers << 2
        end
      end
    end
    @rule_context = ErpRules::RulesEngine::Context.new
  end

  it 'should invoke the rules engine class passed in' do
    @rule_context[:customer_last_name] = "Smith"
    @rule_context[:valid_offers] = []

    @result_ctx = subject.invoke(RuleBook,
                   @rule_context,
                   ErpRules::RulesEngine::Ruleby::Engine)
    @result_ctx[:valid_offers].should include(2)
  end

  it 'should add a directives map if they exist'
end
