module ErpTxnsAndAccts
  class Engine < Rails::Engine
    isolate_namespace ErpTxnsAndAccts
	
    ActiveSupport.on_load(:active_record) do
      include ErpTxnsAndAccts::Extensions::ActiveRecord::ActsAsBizTxnAccount
      include ErpTxnsAndAccts::Extensions::ActiveRecord::ActsAsBizTxnEvent
      include ErpTxnsAndAccts::Extensions::ActiveRecord::ActsAsFinancialTxnAccount
    end

    #TODO
    #this will be removed once rails 3.2 adds the ability to set the order of engine loading
    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
  end
end
