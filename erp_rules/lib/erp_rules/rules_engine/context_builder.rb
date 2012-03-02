module ErpRules
  module RulesEngine
    class ContextBuilder

      @facts = nil
      @execution_context = nil

      def initialize(facts)
        @facts = facts
      end

      def build_execution_context(options={})
        if options[:only].blank?
          execution_context = {
            :environment_context => self.environment_context(),
            :search_context => self.search_context(),
            :customer_context => self.customer_context()
          }
        else
          execution_context = {}
          options[:only].each do |context|
            execution_context[context] = self.send(context)
          end
        end

        ErpRules::RulesEngine::Context.new execution_context
      end

      def persist_context(txn_type, txn_sub_type)
        unless @execution_context.nil?
          search_txn = SearchTxn.new
          search_txn.biz_txn_event = BizTxnEvent.new
          search_txn.biz_txn_event.biz_txn_type = BizTxnType.find_by_type_and_subtype(txn_type,txn_sub_type)
          search_txn.biz_txn_event.description = "#{txn_type} , #{txn_sub_type}"

          build_and_save_context(SearchTxnContext, @execution_context[:search].to_json, search_txn.biz_txn_event) unless @execution_context[:search].nil?
          build_and_save_context(CustomerTxnContext, @execution_context[:customer].to_json, search_txn.biz_txn_event) unless @execution_context[:customer].nil?
          build_and_save_context(EnvironmentTxnContext, @execution_context[:environment].to_json, search_txn.biz_txn_event) unless @execution_context[:environment].nil?
        end
      end

      def search_context()
        logger.warn "ContextBuilder.search_context() is an abstract method"
      end

      def customer_context()
      end

      def environment_context()
        env_txn_context = {
          :time       => @facts[:time],
          :user_agent => @facts[:user_agent],
          :url        => @facts[:url],
          :remote_ip  => @facts[:remote_ip]
        }
        env_txn_context
      end

      def build_and_save_context(context_klass, json, biz_txn_event)
        txn_context = context_klass.new
        txn_context.base_txn_context = BaseTxnContext.new
        txn_context.base_txn_context.biz_txn_event = biz_txn_event
        txn_context.context = json
        txn_context.save
      end

    end
  end
end

