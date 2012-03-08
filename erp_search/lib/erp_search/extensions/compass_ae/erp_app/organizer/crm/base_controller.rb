module ErpApp
  module Organizer
    module Crm
      BaseController.class_eval do
        
        # setup dynamic data grid
        def setup
          columns=[]
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Description", :name => 'description', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "First Name", :name => 'current_first_name', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Last Name", :name => 'current_last_name', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Phone", :name => 'party_phone_number', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Email", :name => 'party_email_address', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Username", :name => 'user_login', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Address", :name => 'party_address_1', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "City", :name => 'party_primary_address_city', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "State", :name => 'party_primary_address_state', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Zip", :name => 'party_primary_address_zip', :xtype => 'textfield' })

          definition = []
          definition << DynamicFormField.textfield({ :fieldLabel => "First Name", :name => 'current_first_name', :mapping => 'individual_current_first_name' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Last Name", :name => 'current_last_name', :mapping => 'individual_current_last_name' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Phone", :name => 'party_phone_number' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Email", :name => 'party_email_address' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Username", :name => 'user_login' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Address", :name => 'party_address_1' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Address Line 2", :name => 'party_address_2' })
          definition << DynamicFormField.textfield({ :fieldLabel => "City", :name => 'party_primary_address_city' })
          definition << DynamicFormField.textfield({ :fieldLabel => "State", :name => 'party_primary_address_state' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Zip", :name => 'party_primary_address_zip' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Country", :name => 'party_primary_address_country' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Description", :name => 'description', :mapping => 'party_description' })

          definition << DynamicFormField.hidden({ :fieldLabel => "ID", :name => 'id' })
          definition << DynamicFormField.hidden({ :fieldLabel => "Party ID", :name => 'party_id' })
          definition << DynamicFormField.hidden({ :fieldLabel => "business_party_type", :name => 'business_party_type', :mapping => 'party_business_party_type' })
          definition << DynamicFormField.hidden({ :fieldLabel => "Enterprise ID", :name => 'enterprise_identifier', :mapping => 'eid' })
          definition << DynamicFormField.hidden({ :fieldLabel => "Date of Birth", :name => 'birth_date', :mapping => 'individual_birth_date' })

          render :inline => "{
            \"success\": true,
            \"columns\": [#{columns.join(',')}],
            \"fields\": #{definition.to_json}
          }"
        end

        def search_parties
          options = {
            :query => (params[:query] || ''),
            :page => (params[:page] || 1),
            :per_page => (params[:per_page] || 20),
            :sort => (params[:sort] || '').downcase,
            :dir => (params[:dir] || 'asc').downcase
          }
          results = Party.do_search(options)

          { :total => results.total_entries, :data => results }.to_json
        end
        protected
        def find_party
          if params[:party_id]
            @party = PartySearchFact.find(params[:party_id]).party rescue nil
          end

          if @party.nil?
            @party = PartySearchFact.find(params[:id]).party rescue nil
          end            
        end

      end
    end
  end
end
