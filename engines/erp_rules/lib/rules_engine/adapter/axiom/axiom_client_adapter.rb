# To change this template, choose Tools | Templates
# and open the template in the editor.

module RulesEngine::Adapter::Axiom
  class AxiomClientAdapter
    include Singleton

    # this invoke makes a call to the local axiom server

    def invoke(ruleset, context)
      Rails.logger.debug("using AXIOM RULE INVOKER")

      #if(ruleset.include?('reservation_search'))
      if(ruleset !=nil)
       # Rails.logger.info("search terms:#{context[:search][:search_terms]}")
       # Rails.logger.info("message: #{context[:message]}")

        axiom_host=ENV['AXIOM_HOST']
        axiom_port=ENV['AXIOM_PORT']

        Rails.logger.info("AXIOM CLIENT HOST:#{axiom_host}")
        Rails.logger.info("AXIOM CLIENT PORT:#{axiom_port}")
        if((axiom_host==nil)&&(axiom_port==nil))
          # create an instance of the axiom client (with defaults host='localhost',port=1099)
          Rails.logger.info("AXIOM CLIENT -DEFAULT CONFIGURATION")
          axiom_client = AxiomClient.new
        else
          # create an instance of the axiom client with host and port set by environment vars
          # axiom_host=ENV['AXIOM_HOST']
          # axiom_port=ENV['AXIOM_PORT']
          axiom_client = AxiomClient.new(axiom_host,axiom_port)
        end
        #invoke the axiom client
        rule_result=axiom_client.invoke(ruleset,context)
        Rails.logger.info("Axiom rule result->#{rule_result}")
        return rule_result
      end
    end
  end
end
