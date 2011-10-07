module ErpApp
  module Organizer
    module Crm
      class RelationshipController < ErpApp::Organizer::BaseController


        #RESTful controller for party relationship
        #data
        def index

          render :inline => if request.get?
            get_party_relationships
          end
        end

        # This method returns all party relationships
        # that involve the params[:party_id] and the passed in
        # relationship type.  Use this when you just need generic
        # information about a relationship passed back.
        # Formats into a hash for consumption by an
        # ExtJS GridPanel
        #
        def get_party_relationships
          party = Party.find(params[:party_id])
          relationships = party.find_relationships_by_type(params[:relationship_type])

          total_count = relationships.length

          {:totalCount => total_count,
            :data => relationships.collect do |relation|
              related_party = relation.to_party
              {
                :party_id => related_party.id,
                :party_desc => related_party.description,
                :relationship => relation.description,
                :created_at => relation.created_at,
                :updated_at => relation.updated_at,
                :from_date => relation.from_date,
                :thru_date => relation.thru_date,
                :role_type => relation.to_role
              }
            end
          }.to_json
        end
      end
    end
  end
end

