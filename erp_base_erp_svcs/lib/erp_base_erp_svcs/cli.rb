Signal.trap("INT") { puts; exit(1) }

require 'erp_base_erp_svcs/commands/compass_ae'

ErpBaseErpSvcs::CompassAE.run
