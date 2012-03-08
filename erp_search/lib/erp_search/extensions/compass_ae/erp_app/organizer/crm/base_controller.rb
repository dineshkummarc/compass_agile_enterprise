module ErpApp
  module Organizer
    module Crm
      BaseController.class_eval do

        # setup dynamic data grid
        def setup
          columns=[]
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Description", :name => 'party_description', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Username", :name => 'user_login', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "First Name", :name => 'individual_current_first_name', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Last Name", :name => 'individual_current_last_name', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Phone", :name => 'party_phone_number', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Email", :name => 'party_email_address', :xtype => 'textfield' })

          definition = []
          definition << DynamicFormField.textfield({ :fieldLabel => "Description", :name => 'party_description' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Username", :name => 'user_login' })
          definition << DynamicFormField.datefield({ :fieldLabel => "First Name", :name => 'individual_current_first_name' })
          definition << DynamicFormField.datefield({ :fieldLabel => "Last Name", :name => 'individual_current_last_name' })
          definition << DynamicFormField.datefield({ :fieldLabel => "Phone", :name => 'party_phone_number' })
          definition << DynamicFormField.datefield({ :fieldLabel => "Email", :name => 'party_email_address' })
          definition << DynamicFormField.hidden({ :fieldLabel => "ID", :name => 'id' })
          definition << DynamicFormField.hidden({ :fieldLabel => "Party ID", :name => 'party_id' })
          definition << DynamicFormField.hidden({ :fieldLabel => "business_party_type", :name => 'party_business_party_type' })

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