require "erp_dev_svcs/engine"
require 'factory_girl'
#include factories
Dir.glob(File.dirname(__FILE__) + '/erp_dev_svcs/factories/*') {|file| require file}
require 'erp_dev_svcs/controller_support/controller_support'

module ErpDevSvcs

end
