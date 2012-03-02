require 'ruleby'
module ErpRules
  module RulesEngine
    module Ruleby
      #Adapter to invoke the Ruleby engine with a rulebook.
      #Intended to be used with the RulesFacade class
      class Engine
        extend ::Ruleby

        def self.invoke(rule_book, context)
          engine :engine do |e|
            rule_book.new(e).rules

            e.assert context
            e.match
            e.retract context
          end
          context
        end

      end
    end
  end
end
