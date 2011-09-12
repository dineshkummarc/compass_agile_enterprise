class ProdAvailabilityStatusType < ActiveRecord::Base
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods
  acts_as_erp_type
end