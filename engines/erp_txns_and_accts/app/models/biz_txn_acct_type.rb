class BizTxnAcctType < ActiveRecord::Base

  acts_as_nested_set
  include TechServices::Utils::DefaultNestedSetMethods

  # For Rails 2.1: override default of include_root_in_json
  # (the Ext.tree.TreeLoader cannot use the additional nesting)
  BizTxnAcctType.include_root_in_json = false if BizTxnAcctType.respond_to?(:include_root_in_json)

end
