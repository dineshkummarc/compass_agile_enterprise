class Cost < ActiveRecord::Base
  belongs_to :money, :class_name => "ErpBaseErpSvcs::Money"
end
