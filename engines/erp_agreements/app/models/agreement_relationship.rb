class AgreementRelationship < ActiveRecord::Base
  unloadable

  belongs_to :agreement_from, :class_name => "Agreement", :foreign_key => "agreement_id_from"  
  belongs_to :agreement_to, :class_name => "Agreement", :foreign_key => "agreement_id_to"

  belongs_to :from_role , :class_name => 'AgreementRoleType', :foreign_key => 'role_type_id_from'
  belongs_to :to_role ,   :class_name => 'AgreementRoleType', :foreign_key => 'role_type_id_to'
  
  belongs_to :relationship_type, :class_name => 'AgreementRelnType', :foreign_key => 'agreement_reln_type_id'

    #convenience class methods to return an instance of this class with the from_role, to_role and
    #relationship_type set using an internal_identifier for the relationship_type. Note that 
    #you still need to set the from and to parties and any contracts / accounts.
    
    def self.for_relationship_type( rel_type )  
    	relationship_type = rel_type
    	reln = self.new
    	reln.relationship_type = relationship_type
    	reln.from_role = relationship_type.valid_from_role
    	reln.to_role = relationship_type.valid_to_role
    	return reln
	end    

    def self.for_relationship_type_identifier( internal_identifier )  
    	relationship_type = AgreementRelnType.find_by_internal_identifier( internal_identifier )
    	reln = self.for_relationship_type( relationship_type )
    	return reln
	end

	#this is a shortcut for the 'self.for_relationship_type_identifier( internal_identifier )' method
    def self.for_reln_type_id( internal_identifier )  
		self.for_relationship_type_identifier( internal_identifier )
	end

end
