module ErpTxnsAndAccts
  class Engine < Rails::Engine
    isolate_namespace ErpTxnsAndAccts
	
	ActiveSupport.on_load(:active_record) do
      include ErpTxnsAndAccts::Extensions::ActiveRecord::ActsAsBizTxnAccount
      include ErpTxnsAndAccts::Extensions::ActiveRecord::ActsAsBizTxnEvent
	  include ErpTxnsAndAccts::Extensions::ActiveRecord::ActsAsFinancialTxnAccount
    end
	
	  #set engine to scope
  	engine = self
  	config.to_prepare do 
  		#load extensions for engine
  		engine.load_extensions
  	end
  end
end
