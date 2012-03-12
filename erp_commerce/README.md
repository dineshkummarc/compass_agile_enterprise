#ErpCommerce

The CompassAE Commerce Engine uses the engines that implement Parties, Products and Orders, and adds the ability to conduct commerce. It implements a pricing engine, fees, payment gateways.

### Override Initializer

To override these settings simple create a erp_commerce.rb file in your initializers and override the config options you want

    Rails.application.config.erp_commerce.configure do |config|
      config.encryption_key                   = 'my_secret_code'
      config.active_merchant_gateway_wrapper = ErpCommerce::ActiveMerchantWrappers::BrainTreeGatewayWrapper
    end
    Rails.application.config.erp_commerce.configure!
