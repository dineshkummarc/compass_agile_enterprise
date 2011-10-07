Party.class_eval do

  #************************************************************************************************
  #** relationship Methods
  #************************************************************************************************


  # Gathers all party relationships that contain this particular party id
  # on the from side
  def relationships
    @relationships ||= PartyRelationship.where('party_id_from = ?', id)
  end

  # Creates a new PartyRelationship for this particular
  # party instance.
  def create_relationship(description, to_party_id)
    PartyRelationship.create(:description => description, :party_id_from => id, :party_id_to => to_party_id)
  end


  # Get only the relationships this party is involved in with the
  # passed in internal_identifier.
  # TODO: Move all this to SQL
  def find_relationships_by_type(relationship_type)
    valid_relations_for_type = []

    #TODO: Log this instead of raising an exception
    #raise ArgumentError, "No relationships apply for the relationship_type passed" if @relationships == nil
    if relationships != nil
      @relationships.each do |item|
        if item.relationship_type.internal_identifier == relationship_type
          valid_relations_for_type << item
        end
      end
    end

    valid_relations_for_type
  end
end
