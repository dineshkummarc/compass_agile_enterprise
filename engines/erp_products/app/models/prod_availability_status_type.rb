class ProdAvailabilityStatusType < ActiveRecord::Base
  acts_as_nested_set
  include TechServices::Utils::DefaultNestedSetMethods
  acts_as_erp_type
end