class AuditLogType < ActiveRecord::Base
  acts_as_nested_set
  acts_as_erp_type
  has_many :audit_logs
  belongs_to_erp_type :parent, :class_name => "AuditLogType"
  
  # this method handles default behavior for find by type and subtype
  def self.find_by_type_and_subtype(txn_type, txn_subtype)
    self.find_by_type_and_subtype_eid(txn_type, txn_subtype)
  end
  
  # find by type Internal Identifier and subtype Internal Identifier
  def self.find_by_type_and_subtype_iid(txn_type, txn_subtype)
    result = nil
	txn_type_recs = find_all_by_internal_identifier(txn_type.strip)
	txn_type_recs.each do |txn_type_rec|
      txn_subtype_rec = find_by_parent_id_and_internal_identifier(txn_type_rec.id, txn_subtype.strip)
      result = txn_subtype_rec 
	  unless txn_subtype_rec.nil?
		result = txn_subtype_rec 
		break
	  end
    end unless txn_type_recs.blank?
    
	result
  end
  
  # find by type External Identifier and subtype External Identifier
  def self.find_by_type_and_subtype_eid(txn_type, txn_subtype)
    result = nil
	txn_type_recs = find_all_by_internal_identifier(txn_type.strip)
	txn_type_recs.each do |txn_type_rec|
      txn_subtype_rec = find_by_parent_id_and_external_identifier(txn_type_rec.id, txn_subtype.strip)
      result = txn_subtype_rec 
	  unless txn_subtype_rec.nil?
		result = txn_subtype_rec 
		break
	  end
    end unless txn_type_recs.blank?
    
	result
  end
		 	
end
