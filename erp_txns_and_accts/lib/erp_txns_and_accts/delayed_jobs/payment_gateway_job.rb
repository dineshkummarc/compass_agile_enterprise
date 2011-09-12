module ErpTxnsAndAccts
	module DelayedJobs
		class PaymentGatewayJob
		  def self.start(financial_txn, gateway, gateway_action, gateway_options, credit_card)
			job_object = ErpTxnsAndAccts::DelayedJobs::PaymentGatewayJob.new(financial_txn.id, gateway.name.to_s, gateway_action, gateway_options, credit_card)
			Delayed::Job.enqueue(job_object, 50, 1.seconds.from_now)
		  end

		  def initialize(financial_txn_id, gateway_klass, gateway_action, gateway_options, credit_card)
			@financial_txn_id = financial_txn_id
			@gateway_klass    = gateway_klass
			@gateway_action   = gateway_action
			@gateway_options  = gateway_options
			@credit_card      = credit_card
		  end

		  def perform
			gateway = @gateway_klass.constantize
			financial_txn = FinancialTxn.find(@financial_txn_id)
			financial_txn.send(@gateway_action, @credit_card, gateway, @gateway_options)
		  end
		end
	end
end
