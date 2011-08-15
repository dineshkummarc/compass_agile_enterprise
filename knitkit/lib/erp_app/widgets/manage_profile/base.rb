module ErpApp
  module Widgets
    module ManageProfile
      class Base < ErpApp::Widgets::Base
        def contact_purpose_in_use?(contacts, purpose)
          result = false
          contacts.each do |e|
            if e.contact.contact_purposes[0].internal_identifier == purpose
              result = true
            else
              result = false
            end
          end  
          result
        end

        def index
          @user = User.find(current_user)
          @individual = @user.party.business_party
          @email_addresses = @user.party.find_all_contacts_by_contact_mechanism(EmailAddress)
          @phone_numbers = @user.party.find_all_contacts_by_contact_mechanism(PhoneNumber)
          @postal_addresses = @user.party.find_all_contacts_by_contact_mechanism(PostalAddress)
    
          contact_purposes = ContactPurpose.find(:all)
          @purpose_hash={"Type" => "type"}
          contact_purposes.each do |p|
            @purpose_hash[p.description]=p.internal_identifier
          end

      	countries= GeoCountry.find(:all)
          @countries_id=[]
          @countries_id << ["Country", "default"]
      	countries.each do |c|
      	  @countries_id << [c.name, c.id]
      	end
	
      	states= GeoZone.find(:all)
      	@states_id=[]
      	@states_id << ["State", "default"]
      	states.each do |s|
      	  @states_id << [s.zone_name, s.id]
      	end
    
          render
        end
  
        def update_user_information
          #### Get appropriate models ####
    
          @user=User.find(current_user)
          @individual= @user.party.business_party
    
           #### Formating the date for sqlite. Will probably need diffrent formating for production ####
          if params[:date][:day].to_i < 10 
            day="0#{params[:date][:day]}"
          else
            day= params[:date][:day]
          end

          if params[:date][:month].to_i < 10
            month="0#{params[:date][:month]}"
          else
            month= params[:date][:month]
          end
    
          formated_date= "#{params[:date][:year]}-#{month}-#{day}"
    
    
          #### Check if user made changes to info then update ####  
          if @individual.current_first_name != params[:first_name]
            @user.first_name= params[:first_name]
            @individual.current_first_name= params[:first_name]
          end
    
          if @individual.current_last_name != params[:last_name]
            @user.last_name= params[:last_name]
            @individual.current_last_name= params[:last_name]
          end
    
          if @individual.current_middle_name != params[:middle_name]
            @individual.current_middle_name= params[:middle_name]
          end
    
          if @individual.gender != params[:gender]
            @individual.gender= params[:gender]
          end
    
          if @individual.birth_date != formated_date
            @user.dob= formated_date
            @individual.birth_date= formated_date
          end
    
          #### check validation then save and render message ####
          if @user.changed? || @individual.changed?
            if @user.valid? && @individual.valid?
              @user.save
              @individual.save
              render :view => :success
            else
              render :view => :error
            end
          end
    
        end
  

        def update_password
          @user= User.find(current_user)
    
          if @user.authenticated? params[:old_password]
            if params[:new_password] != "" && params[:password_confirmation] != "" && params[:new_password] == params[:password_confirmation]
      		
              @user.password= params[:new_password]
              @user.password_confirmation= params[:password_confirmation]
      
              if @user.valid?
                @user.save
                render :view => :password_success
              else
                #### validation failed ####
                render :view => :error
              end
        
            else
              #### password and password confirmation cant be blank or unequal ####
              render :view => :password_blank
            end
          else
            #### old password wrong ####
            render :view => :password_invalid
          end
      
        end
  
        def update_contact_information
          @user= User.find(current_user)
          @email_addresses= @user.party.find_all_contacts_by_contact_mechanism(EmailAddress)
          @phone_numbers= @user.party.find_all_contacts_by_contact_mechanism(PhoneNumber)
          @postal_addresses= @user.party.find_all_contacts_by_contact_mechanism(PostalAddress)
          something_changed=false
          contact_type_in_use=false
          default_type_error=false
    
          #### Updates email records ####
          @email_addresses.each_with_index do |e, i|
            email_address_args={}
            if e.email_address != params[:email_addresses][i.to_s]
              email_address_args={:email_address => params[:email_addresses][i.to_s]}
              @user.party.update_or_add_contact_with_purpose(EmailAddress, 
              	ContactPurpose.find_by_internal_identifier(params[:email_address_contact_purposes][i.to_s]), 
              	email_address_args)
              something_changed=true
            end
          end
    
         #### Updates Phone Numbers #### 
          @phone_numbers.each_with_index do |p, i|
            phone_number_args={}
            if p.phone_number != params[:phone_numbers][i.to_s]
              phone_number_args={:phone_number => params[:phone_numbers][i.to_s]}
              @user.party.update_or_add_contact_with_purpose(PhoneNumber, 
              	ContactPurpose.find_by_internal_identifier(params[:phone_number_contact_purposes][i.to_s]), 
              	phone_number_args)
              something_changed=true
            end
          end
    
          #### Updates Postal Addresses
          @postal_addresses.each_with_index do |a, i|
            postal_address_args= {}
      
            if a.address_line_1 != params[:postal_addresses][i.to_s][:address_line_1]
              postal_address_args[:address_line_1]= params[:postal_addresses][i.to_s][:address_line_1]
            end
      
            if a.address_line_2 != params[:postal_addresses][i.to_s][:address_line_2]
              postal_address_args[:address_line_2]= params[:postal_addresses][i.to_s][:address_line_2]
            end
      
            if a.city != params[:postal_addresses][i.to_s][:city]
              postal_address_args[:city]= params[:postal_addresses][i.to_s][:city]
            end
      
            if a.geo_zone_id != params[:postal_addresses][i.to_s][:state_id].to_i
              postal_address_args[:geo_zone_id]= params[:postal_addresses][i.to_s][:state_id].to_i
              postal_address_args[:state]= GeoZone.find(params[:postal_addresses][i.to_s][:state_id]).zone_name
            end
      
            if a.zip != params[:postal_addresses][i.to_s][:zip]
              postal_address_args[:zip]= params[:postal_addresses][i.to_s][:zip]
            end
      
            if a.geo_country_id != params[:postal_addresses][i.to_s][:country_id].to_i
              postal_address_args[:geo_country_id]= params[:postal_addresses][i.to_s][:country_id].to_i
              postal_address_args[:country]= GeoCountry.find(params[:postal_addresses][i.to_s][:country_id]).name
            end
      
            if !postal_address_args.empty? 
              @user.party.update_or_add_contact_with_purpose(PostalAddress, 
              	ContactPurpose.find_by_internal_identifier(params[:postal_address_contact_purposes][i.to_s]), 
              	postal_address_args)
              something_changed=true
            end
          end
    
          #### Adds new email address ####
          if params[:new_email_address] != nil && params[:new_email_address] != "" 
            if params[:new_email_address_contact_purpose] != "type"
              if !contact_purpose_in_use?(@email_addresses, params[:new_email_address_contact_purpose])
                @user.party.update_or_add_contact_with_purpose(EmailAddress,
              	ContactPurpose.find_by_internal_identifier(params[:new_email_address_contact_purpose]),
              	:email_address => params[:new_email_address])
                something_changed=true
              else
                contact_type_in_use=true
                #render :view => :contact_type_in_use
              end
            else
              default_type_error=true
              #render :view => :default_type_error
            end
          end
    
          #### Adds new phone number ####
          if params[:new_phone_number] != nil && params[:new_phone_number] != ""
            if params[:new_phone_number_contact_purpose] != "type"
              if !contact_purpose_in_use?(@phone_numbers, params[:new_phone_number_contact_purpose])
                @user.party.update_or_add_contact_with_purpose(PhoneNumber,
              	ContactPurpose.find_by_internal_identifier(params[:new_phone_number_contact_purpose]),
              	:phone_number => params[:new_phone_number])
                something_changed=true
              else
                contact_type_in_use=true
                #render :view => :contact_type_in_use
              end
            else
              default_type_error=true
              #render :view => :default_type_error
            end
          end
    
          #### Adds new postal address ####
          new_postal_address_args= {}
      
          if params[:new_postal_address][:address_line_1] != "Address Line 1"
            new_postal_address_args[:address_line_1]= params[:new_postal_address][:address_line_1]
          end
      
          if params[:new_postal_address][:address_line_2] != "Address Line 2"
            new_postal_address_args[:address_line_2]= params[:new_postal_address][:address_line_2]
          end
      
          if params[:new_postal_address][:city] != "City"
            new_postal_address_args[:city]= params[:new_postal_address][:city]
          end
      
          if params[:new_postal_address][:state_id] != "default"
            new_postal_address_args[:geo_zone_id]= params[:new_postal_address][:state_id].to_i
            new_postal_address_args[:state]= GeoZone.find(params[:new_postal_address][:state_id]).zone_name
          end
      
          if params[:new_postal_address][:zip] != "Zipcode"
            new_postal_address_args[:zip]= params[:new_postal_address][:zip]
          end
      
          if params[:new_postal_address][:country_id] != "default"
            new_postal_address_args[:geo_country_id]= params[:new_postal_address][:country_id].to_i
            new_postal_address_args[:country]= GeoCountry.find(params[:new_postal_address][:country_id]).name
          end
      
          if !new_postal_address_args.empty?  
            if params[:new_postal_address_contact_purpose] != "type"
              if !contact_purpose_in_use?(@postal_addresses, params[:new_postal_address_contact_purpose])
                @user.party.update_or_add_contact_with_purpose(PostalAddress, 
              	ContactPurpose.find_by_internal_identifier(params[:new_postal_address_contact_purpose]), 
              	new_postal_address_args)
                something_changed=true
              else
                contact_type_in_use=true
                #render :view => :contact_type_in_use
              end
            else
              default_type_error=true
              #render :view => :default_type_error
            end
          end
    
          #### Renders proper error or success message ####
          if default_type_error
            render :view => :default_type_error
          elsif contact_type_in_use
            render :view => :contact_type_in_use
          elsif something_changed
            render :view => :success
          end
    
        end

        #should not be modified
        #modify at your own risk
        self.view_paths = File.join(File.dirname(__FILE__),"/views")
        
        def locate
          File.dirname(__FILE__)
        end
        
        class << self
          def title
            "Manage Profile"
          end
          
          def widget_name
            File.basename(File.dirname(__FILE__))
          end
          
          def base_layout
            begin
              file = File.join(File.dirname(__FILE__),"/views/layouts/base.html.erb")
              IO.read(file)
            rescue
              return nil
            end
          end
        end
      end
    end
  end
end
