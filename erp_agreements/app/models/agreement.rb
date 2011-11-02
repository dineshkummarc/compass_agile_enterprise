class Agreement < ActiveRecord::Base

	belongs_to :agreement_type
	has_many 	 :agreement_items
	has_many 	 :agreement_party_roles
	has_many	 :parties, :through => :agreement_party_roles
  belongs_to :agreement_record, :polymorphic => true, :dependent => :destroy
  
  alias :items :agreement_items
  
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
    agreement_items.joins("join agreement_item_types on 
                           agreement_item_types.id = 
                           agreement_items.agreement_item_type_id").where("agreement_item_types.internal_identifier = '#{item_type_internal_identifier}'").first
  end
  
  def respond_to?(m)
    ((get_item_by_item_type_internal_identifier(m.to_s).nil? ? false : true)) unless super
  end
  
  def method_missing(m, *args, &block)
    agreement_item = get_item_by_item_type_internal_identifier(m.to_s)
    (agreement_item.nil?) ? super : (return agreement_item.agreement_item_value)
  end

end
