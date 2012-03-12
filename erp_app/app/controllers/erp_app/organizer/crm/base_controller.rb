module ErpApp
	module Organizer
		module Crm
			class BaseController < ErpApp::Organizer::BaseController
        @@date_format = "%m/%d/%Y"
        @@datetime_format = "%m/%d/%Y %l:%M%P"
        before_filter :find_party

        def index
          render :inline => if request.get?
            search_parties
          elsif request.delete?
            delete_party
          end          
        end

        # setup dynamic data grid
        def setup
          columns=[]
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Description",
                                                      :name => 'description',
                                                      :xtype => 'textfield' })
          #columns << DynamicGridColumn.build_column({ :fieldLabel => "Username", :name => 'username', :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Tax ID #",
                                                      :name => 'tax_id_number',
                                                      :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "First Name",
                                                      :name => 'current_first_name',
                                                      :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Last Name",
                                                      :name => 'current_last_name',
                                                      :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => 'Middle Name',
                                                      :name => 'current_middle_name',
                                                      :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => 'Title',
                                                      :name => 'current_personal_title',
                                                      :xtype => 'textfield' })
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Gender", 
                                                      :name => 'gender',
                                                      :xtype => 'textfield'})
          columns << DynamicGridColumn.build_column({ :fieldLabel => "Birth Date",
                                                      :name => 'birth_date',
                                                      :xtype => 'datefield' })



          definition = []
          definition << DynamicFormField.textfield({ :fieldLabel => "Description",
                                                     :name => 'description' })
          #definition << DynamicFormField.textfield({ :fieldLabel => "Username", :name => 'username', :mapping => 'user.username' })
          definition << DynamicFormField.textfield({ :fieldLabel => "First Name",
                                                     :name => 'current_first_name',
                                                     :mapping => 'business_party.current_first_name' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Last Name",
                                                     :name => 'current_last_name',
                                                     :mapping => 'business_party.current_last_name' })
          definition << DynamicFormField.textfield({ :fieldLabel => "Middle Name",
                                                     :name => 'current_middle_name',
                                                     :mapping => 'business_party.current_middle_name' })
          definition << DynamicFormField.textfield({ :fieldLabel => 'Title',
                                                     :name => 'current_personal_title',
                                                     :mapping => 'business_party.current_personal_title' })
          definition << DynamicFormField.hidden({ :fieldLabel => "ID", :name => 'id' })
          definition << DynamicFormField.hidden({ :fieldLabel => "Party ID", :name => 'party_id' })
          definition << DynamicFormField.hidden({ :fieldLabel => "business_party_id",
                                                  :name => 'business_party_id',
                                                  :mapping => 'business_party.id' })
          definition << DynamicFormField.hidden({ :fieldLabel => "business_party_type",
                                                  :name => 'business_party_type' })

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
          parties = Party.do_search(options)

          party_hash = {
            :total => parties.total_entries, 
            :data => parties.collect{|party| {
              :description => party.description,
              :id => party.id,
              :enterprise_identifier => party.enterprise_identifier,
              :created_at => party.created_at,
              :updated_at => party.updated_at,
              :business_party_type => party.business_party_type,
              :business_party => party.business_party,
              :user => party.user
            }}
          }

          party_hash.to_json
        end

			  def menu
          menu = []

          menu << {:text => 'Search Customers', :businessPartType => 'individual', :leaf => true, :iconCls => 'icon-user', :applicationCardId => "individuals_search_grid"}
          menu << {:text => 'Search Accounts', :leaf => true, :iconCls => 'icon-creditcards', :applicationCardId => "billpay-application"}
          #menu << {:text => 'Organizations',:businessPartType => 'organization', :leaf => true, :iconCls => 'icon-user', :applicationCardId => "organizations_search_grid"}

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
            params.delete(:authenticity_token)

            params[:birth_date] = Date.strptime(params[:birth_date], @@date_format) unless params[:birth_date].blank?
            params[:current_passport_expire_date] = Date.strptime(params[:current_passport_expire_date], @@date_format) unless params[:current_passport_expire_date].blank?

            business_party = klass.create(params)
            business_party.party.enterprise_identifier = enterprise_identifier
            business_party.party.save

            result = {:success => true, :message => "#{party_type} Added", :name => business_party.party.description}
          rescue Exception=>ex
            result = {:success => false, :message => "Error adding #{party_type}"}
          end

          render :json => result
			  end

			  def update_party
          enterprise_identifier = params[:enterprise_identifier]
          party_type = params[:party_type]
          businesss_party_id = params[:business_party_id]
          business_party_data = params
          business_party_data.delete(:id)
          business_party_data.delete(:business_party_id)
          business_party_data.delete(:enterprise_identifier)
          business_party_data.delete(:authenticity_token)
          business_party_data.delete(:party_type)
          business_party_data.delete(:controller)
          business_party_data.delete(:action)
          business_party_data[:birth_date] = Date.strptime(business_party_data[:birth_date], @@date_format) unless business_party_data[:birth_date].blank?
          business_party_data[:current_passport_expire_date] = Date.strptime(business_party_data[:current_passport_expire_date], @@date_format) unless business_party_data[:current_passport_expire_date].blank?

          business_party = @party.business_party

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

          render :json => { :success => true,
                :message => "#{party_type} updated", 
                :data => [{
                  :id => party.id,
                  :enterprise_identifier => party.enterprise_identifier,
                  :created_at => party.created_at,
                  :updated_at => party.updated_at,
                  :business_party => party.business_party,
                  :user => party.user
                }]
          }
			  end

        def get_party_details
          @party          
        end

        def get_user
          party = @party rescue nil

          if params[:party_id] and !party.nil?
            user = party.user
            if user.nil?
              success = true
              message = "User Does Not Exist"
              u = {
                :username => '',
                :email => '',
                :activation_state => '',
                :last_login_at => '',
                :failed_logins_count => '',
                :activation_token => ''
              }
            else
              success = true
              message = "User Found"

              last_login_at = user.last_login_at.blank? ? '' : user.last_login_at.getlocal.strftime(@@datetime_format)

              u = {
                :username => user.username,
                :email => user.email,
                :activation_state => user.activation_state,
                :last_login_at => last_login_at,
                :failed_logins_count => user.failed_logins_count,
                :activation_token => user.activation_token
              }
            end
          else
            success = false
            message = "Party Not Found"
            u = {}
          end

          render :json => { :success => success,
                            :message => message,
                            :data => [u] 
                          }
        end

        def update_user
          party = @party rescue nil

          if params[:party_id] and !party.nil?
            user = party.user
            if user.nil?
              success = true
              message = "User Does Not Exist"              
            else              
              user.username = params[:username]
              user.email = params[:email]
              if user.save
                success = true
                message = "User Successfully Updated"
              else
                success = false
                message = 'Update Failed'
              end
            end
          else
            success = false
            message = "Party Not Found"
          end

          render :json => { :success => success, :message => message } and return
        end

        def activate
          if @user = User.load_from_activation_token(params[:activation_token])
            @user.activate!
            success = true
            message = 'User was successfully activated.'
          else
            success = false
            message = "Invalid activation token."
          end

          render :json => { :success => success, :message => message } and return
        end

        private

        def page
          offset = params[:start].to_f
          offset > 0 ? (offset / params[:limit].to_f).to_i + 1 : 1
        end
        
        def per_page
          params[:limit].nil? ? 20 : params[:limit].to_i
        end  

			  # def get_parties
     #      search_name = params[:party_name]
     #      party_type = params[:party_type]
     #      start = params[:start] || 0
     #      limit = params[:limit] || 30

     #      parties = Party.where("description like ? and business_party_type = ?", "%#{search_name}%", party_type)
     #      total_count = parties.count
     #      parties = parties.order("id").offset(start).limit(limit)

     #       {:totalCount => total_count, :data => parties.collect{|party| {
     #            :id => party.id,
     #            :enterprise_identifier => party.enterprise_identifier,
     #            :created_at => party.created_at,
     #            :updated_at => party.updated_at,
     #            :business_party => party.business_party
     #          }}
     #      }.to_json
			  # end

			  def delete_party
          party_type = params[:party_type]
          @party.destroy

          {:data => [], :message => "#{party_type} deleted"}.to_json
			  end

			  def create_contact_mechanism
          party_id = params[:party_id]
          contact_type = params[:contact_type]
          contact_purpose_id = params[:data][:contact_purpose_id]
          params[:data].delete(:contact_purpose_id)

          contact_mechanism_class = contact_type.constantize
          
          contact_purpose = contact_purpose_id.blank? ? ContactPurpose.find_by_internal_identifier('default') : ContactPurpose.find(contact_purpose_id)
          contact_mechanism = @party.add_contact(contact_mechanism_class, params[:data], contact_purpose)

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

          contact_type.constantize.class_eval do
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

          contact_mechanisms = @party.find_all_contacts_by_contact_mechanism(contact_mechanism_class)

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

          contact_mechanisms = @party.find_all_contacts_by_contact_mechanism(contact_type_class)
          
          "{\"success\":true, \"data\":#{contact_mechanisms.to_json(:methods => [:contact_purpose_id])},\"message\":\"#{contact_type} deleted\"}"
			  end

        protected
        def find_party
          party_id = params[:party_id] ? params[:party_id] : params[:id]
          @party = Party.find(party_id) rescue nil
        end
			end
		end
	end
end
