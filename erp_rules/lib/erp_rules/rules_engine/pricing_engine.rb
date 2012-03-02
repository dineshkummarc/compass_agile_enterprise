module ErpRules
  module RulesEngine
    class PricingEngine

      def initialize()
      end

      def price_products(execution_context)
        execution_context[:product_context][:products].each do |product|
          pricing_plan = PricingPlan.find_by_internal_identifier('default')
          product[:price] = pricing_plan.get_price()
        end

        execution_context
      end
    end
  end
end
