class AuditLogType < ActiveRecord::Base

	acts_as_nested_set
	include TechServices::Utils::DefaultNestedSetMethods
	acts_as_erp_type
  has_many :audit_logs

  belongs_to_erp_type :parent, :class_name => "AuditLogType"
	
	# For Rails 2.1: override default of include_root_in_json
	# (the Ext.tree.TreeLoader cannot use the additional nesting)
	AuditLogType.include_root_in_json = false if AuditLogType.respond_to?(:include_root_in_json)
		
  	# def self.iid(internal_identifier)
  	# 	self.find( :first, :conditions => ['internal_identifier = ?', internal_identifier] )
  	# end
  	# 
  	# def self.eid(external_identifier)
  	# 	self.find_by_external_identifier(external_identifier)
  	# end

  # this method handles default behavior for find by type and subtype
  def self.find_by_type_and_subtype(txn_type, txn_subtype)
    return self.find_by_type_and_subtype_eid(txn_type, txn_subtype)
  end
  
  # find by type Internal Identifier and subtype Internal Identifier
  def self.find_by_type_and_subtype_iid(txn_type, txn_subtype)
    txn_type_recs = find_all_by_internal_identifier(txn_type.strip)
    return nil if txn_type_recs.blank?
    txn_type_recs.each do |txn_type_rec|
      txn_subtype_rec = find_by_parent_id_and_internal_identifier(txn_type_rec.id, txn_subtype.strip)
      return txn_subtype_rec unless txn_subtype_rec.nil?
    end
    return nil
  end
  
  # find by type External Identifier and subtype External Identifier
  def self.find_by_type_and_subtype_eid(txn_type, txn_subtype)
    txn_type_recs = find_all_by_external_identifier(txn_type.strip)
    return nil if txn_type_recs.blank?
    txn_type_recs.each do |txn_type_rec|
      txn_subtype_rec = find_by_parent_id_and_external_identifier(txn_type_rec.id, txn_subtype.strip)
      return txn_subtype_rec unless txn_subtype_rec.nil?
    end
    return nil
  end
		 	
end
