class Agreement < ActiveRecord::Base

	belongs_to :agreement_type
	has_many 	 :agreement_items
	has_many 	 :agreement_party_roles
	has_many	 :parties, :through => :agreement_party_roles
  belongs_to :agreement_record, :polymorphic => true, :dependent => :destroy
  
  def agreement_relationships
    AgreementRelationship.where('agreement_id_from = ? OR agreement_id_to = ?',id,id)
  end
  
  def to_s
      "#{description}"
  end
 
  def to_label
      to_s
  end

  def find_parties_by_role(role)
    self.parties.includes([:agreement_party_roles]).where("role_type_id = ?", role.id)
  end

  def get_item_by_item_type_internal_identifier(item_type_internal_identifier)
    result = nil
    agreement_items.each do |agreement_item|
      if (agreement_item.agreement_item_type.internal_identifier == item_type_internal_identifier)
        result = agreement_item.agreement_item_value
        break
      end
    end
    result
  end
  
  def respond_to?(m)
    result = true
    if !super
      result = get_item_by_item_type_internal_identifier(m.to_s).nil? ? true : false
    end
    result
  end
  
  def method_missing(m, *args, &block)
    begin
      value = get_item_by_item_type_internal_identifier(m.to_s)
      (value != nil) ? (return value) : super
    rescue
      super
    end
  end

end
