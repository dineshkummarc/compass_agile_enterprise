require "erp_base_erp_svcs/extensions"
require "erp_base_erp_svcs/engine"
require "erp_base_erp_svcs/non_escape_json_string"

module ErpBaseErpSvcs
  ENGINES = [
    "ErpBaseErpSvcs","ErpDevSvcs","ErpTechSvcs","ErpAgreements","ErpTxnsAndAccts",
    "ErpCommerce","ErpCommunicationEvents","ErpFinancialAccounting","ErpInventory",
    "ErpOrders","ErpProducts","ErpWorkEffort","ErpApp","Knitkit","RailsDbAdmin",
    "ErpForms","Console","Tenancy"
    ]
end


