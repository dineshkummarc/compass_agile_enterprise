require 'paperclip'
require 'delayed_job'
require 'devise'
require "erp_tech_svcs/utils/compass_logger"
require "erp_tech_svcs/utils/default_nested_set_methods"
require "erp_tech_svcs/extensions"
require "erp_tech_svcs/engine"
require 'erp_tech_svcs/sessions/delete_expired_sessions_job'
require 'erp_tech_svcs/sessions/delete_expired_sessions_service'

module ErpTechSvcs
end
