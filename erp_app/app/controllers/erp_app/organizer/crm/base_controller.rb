module ErpApp
	module Organizer
		module Crm
			class BaseController < ErpApp::Organizer::BaseController
			  def menu
          menu = []

          menu << {:text => 'Individuals', :businessPartType => 'individual', :leaf => true, :iconCls => 'icon-user', :applicationCardId => "individuals_search_grid"}
          menu << {:text => 'Organizations',:businessPartType => 'organization', :leaf => true, :iconCls => 'icon-user', :applicationCardId => "organizations_search_grid"}

          render :json => menu
			  end

			  def contact_purposes
          render :inline => "{\"types\":#{ContactPurpose.all.to_json(:only => [:id, :description])}}"
			  end

			  def parties
          render :inline => if request.put?
            update_party
          elsif request.get?
            get_parties
          elsif request.delete?
            delete_party
          end
			  end

			  def contact_mechanism
          render :inline => if request.post?
            create_contact_mechanism
          elsif request.put?
            update_contact_mechanism
          elsif request.get?
            get_contact_mechanisms
          elsif request.delete?
            delete_contact_mechanism
          end
			  end

			  def create_party
          result = {}
          begin
            enterprise_identifier = params[:enterprise_identifier]
            party_type = params[:party_type]
            klass = party_type.constantize
            params.delete(:enterprise_identifier)
            params.delete(:action)
            params.delete(:controller)
            params.delete(:party_type)

            business_party = klass.create(params)
            business_party.party.enterprise_identifier = enterprise_identifier
            business_party.party.save

            result = {:success => true, :message => "#{party_type} Added", :name => business_party.party.description}
          rescue Exception=>ex
            result = {:success => false, :message => "Error adding #{party_type}"}
          end

          render :json => result
			  end

			  private

			  def update_party
          party_type = params[:party_type]
          business_party_data = params[:data]
          businesss_party_id = business_party_data['business_party_id']
          enterprise_identifier = business_party_data[:enterprise_identifier]
          business_party_data.delete(:id)
          business_party_data.delete(:business_party_id)
          business_party_data.delete(:enterprise_identifier)

          klass = party_type.constantize
          business_party = klass.find(businesss_party_id)

          business_party_data.each do |key,value|
            key = key.gsub("business_party.", "")
            method = key + '='
            business_party.send method.to_sym, value
          end

          business_party.save
          party = business_party.party

          begin
            party.enterprise_identifier = enterprise_identifier
            party.save
          end unless enterprise_identifier.blank?

          {:message => "#{party_type} updated", :data => [{
                :id => party.id,
                :enterprise_identifier => party.enterprise_identifier,
                :created_at => party.created_at,
                :updated_at => party.updated_at,
                :business_party => party.business_party
              }]
          }.to_json

			  end

			  def get_parties
          search_name = params[:party_name]
          party_type = params[:party_type]
          start = params[:start] || 0
          limit = params[:limit] || 30

          total_count = Party.where("description like ? and business_party_type = ?", "%#{search_name}%", party_type).count
          parties = Party.where("description like ? and business_party_type = ?", "%#{search_name}%", party_type).order("id").offset(start).limit(limit)

           {:totalCount => total_count, :data => parties.collect{|party| {
                :id => party.id,
                :enterprise_identifier => party.enterprise_identifier,
                :created_at => party.created_at,
                :updated_at => party.updated_at,
                :business_party => party.business_party
              }}
          }.to_json
			  end

			  def delete_party
          party_type = params[:party_type]
          Party.destroy(params[:id])

          {:data => [], :message => "#{party_type} deleted"}.to_json
			  end

			  def create_contact_mechanism
          party_id = params[:party_id]
          contact_type = params[:contact_type]
          contact_purpose_id = params[:data][:contact_purpose_id]
          params[:data].delete(:contact_purpose_id)

          contact_mechanism_class = contact_type.constantize
          party = Party.find(party_id)
          
          contact_purpose = contact_purpose_id.blank? ? ContactPurpose.find_by_internal_identifier('default') : ContactPurpose.find(contact_purpose_id)
          contact_mechanism = party.add_contact(contact_mechanism_class, params[:data], contact_purpose)

          contact_mechanism_class.class_eval do
            def contact_purpose_id
              self.contact_purpose ? contact_purpose.id : nil
            end
          end

          "{\"success\":true, \"data\":#{contact_mechanism.to_json(:methods => [:contact_purpose_id])},\"message\":\"#{contact_type} added\"}"
			  end

			  def update_contact_mechanism
          contact_type = params[:contact_type]
          contact_mechanism_id = params[:data][:id]
          contact_purpose_id = params[:data][:contact_purpose_id]
          params[:data].delete(:id)
          params[:data].delete(:contact_purpose_id)
          
          contact_mechanism = contact_type.constantize.find(contact_mechanism_id)

          if !contact_purpose_id.blank?
            contact_purpose = ContactPurpose.find(contact_purpose_id)
            contact_mechanism.contact.contact_purposes.destroy_all
            contact_mechanism.contact.contact_purposes << contact_purpose
            contact_mechanism.contact.save
          end

          params[:data].each do |key,value|
            method = key + '='
            contact_mechanism.send method.to_sym, value
          end

          contact_mechanism.save

          contact_mechanism_class.class_eval do
            def contact_purpose_id
              self.contact_purpose ? contact_purpose.id : nil
            end
          end

          "{\"success\":true, \"data\":#{contact_mechanism.to_json(:methods => [:contact_purpose_id])},\"message\":\"#{contact_type} updated\"}"
			  end

			  def get_contact_mechanisms
          party_id = params[:party_id]
          contact_type = params[:contact_type]

          contact_mechanism_class = contact_type.constantize

          party = Party.find(party_id)
          contact_mechanisms = party.find_all_contacts_by_contact_mechanism(contact_mechanism_class)

          contact_mechanism_class.class_eval do
            def contact_purpose_id
              self.contact_purpose ? contact_purpose.id : nil
            end
          end

          "{\"success\":true, \"data\":#{contact_mechanisms.to_json(:methods => [:contact_purpose_id])}}"
			  end

			  def delete_contact_mechanism
          party_id = params[:party_id]
          contact_type = params[:contact_type]
          contact_mechanism_id = params[:id]

          contact_type_class = contact_type.constantize
          contact_mechanism = contact_type_class.find(contact_mechanism_id)
          contact_mechanism.destroy

          party = Party.find(party_id)
          contact_mechanisms = party.find_all_contacts_by_contact_mechanism(contact_type_class)
          
          "{\"success\":true, \"data\":#{contact_mechanisms.to_json(:methods => [:contact_purpose_id])},\"message\":\"#{contact_type} deleted\"}"
			  end
			end
		end
	end
end