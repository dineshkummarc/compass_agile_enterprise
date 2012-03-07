Dir.glob("#{File.dirname(__FILE__)}/active_merchant_wrappers/**/*.rb").each do |file|
  require "erp_commerce/active_merchant_wrappers/#{File.basename(file)}"
end
