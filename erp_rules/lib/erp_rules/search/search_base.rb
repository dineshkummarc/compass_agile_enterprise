module ErpRules
  module Search
    class SearchBase

      def search facts
        return process_search_facts(facts)
      end

      #This is the vertical search method that will need to be implemented
      #in the sub-class
      def do_search ctx
        raise "do_search needs to be implemented in the subclass"
      end

      #Perform any processing the facts passed by a search controller
      def pre_process_facts facts
        raise "pre_process_facts needs to be implemented in the subclass"
      end

      #This must return an object (class, hash, whatever) that is used by the
      #rules engine as a sort of rule book.
      def generate_rules ctx
        raise "generate_rules must be implemented in the subclass"
      end

      def process_search_facts(facts, search_rules_klass, context_builder_klass=ErpRules::RulesEngine::ContextBuilder)

        # breaking out Orange Lake search logic into a subclass
        # this creates a requirement that this class be extended with a subclass containing pre_process_facts method
        facts = pre_process_facts(facts)

        # build the execution context for the rules engine
        search_execution_context = create_search_execution_context(facts,
                                                                   {:persistant => Constants::SEARCH_TXN_PERSISTANT,
                                                                    :context_builder_klass => context_builder_klass})

        ruleset = generate_rules ctx
        #execute the reservation_search rules and get back some search filtering criteria
        filters = ErpRules::RulesEngine::RulesFacade.new.invoke(ruleset, search_execution_context, search_rules_klass)

        # breaking out Orange Lake search logic into a subclass
        # this creates a requirement that this class be extended with a subclass containing vertical_search method
        res_search_results, message = do_search(facts, filters)

        return res_search_results, message
      end

      def create_search_execution_context(facts, options={})
        options[:persistant] = false if options[:persistant].nil?

        # Get execution context
        context_builder   = options[:context_builder_klass].new(facts)
        execution_context = context_builder.build_execution_context()

        # If persistant, save to database
        if options[:persistant]
          context_builder.persist_context(self.class.to_s, facts[:search_params][:search_type])
        end

        return execution_context
      end
    end
  end
end
