module ErpApp
	module Desktop
		module UserManagement
			class BaseController < ErpApp::Desktop::BaseController
			  before_filter :get_user, :only => [:get_details, :delete]

			  def index
          username = params[:username]
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'username'
          dir  = sort_hash[:direction] || 'ASC'
          limit = params[:limit] || 25
          start = params[:start] || 0
          total_count = 0

          if username.blank?
            users = User.order("#{sort} #{dir}").offset(start).limit(limit)
            total_count = User.count
          else
            users = User.where('username like ?', "%#{username}%").order("#{sort} #{dir}").offset(start).limit(limit)
            total_count = users.count
          end

          render :inline => "{\"totalCount\":#{total_count},data:#{users.to_json(:only => [:id, :username, :email, :party_id])}}"
			  end

			  def new
          response = {}
          application = DesktopApplication.find_by_internal_identifier('user_management')
          begin
            current_user.with_capability(application, :create, 'User') do
            
              user = User.new(
                :email => params[:email],
                :username => params[:username],
                :password => params[:password],
                :password_confirmation => params[:password_confirmation]
              )
              #set this to tell activation where to redirect_to for login and temp password
              user.add_instance_attribute(:login_url, '/erp_app/login');
              user.add_instance_attribute(:temp_password, params[:password]);

              if user.save
                individual = Individual.create(:gender => params[:gender], :current_first_name => params[:first_name], :current_last_name => params[:last_name])
                user.party = individual.party
                user.save

                response = {:success => true}
              else
                message = "<ul>"
                user.errors.collect do |e, m|
                  message << "<li>#{e} #{m}</li>"
                end
                message << "</ul>"
                response = {:success => false, :message => message}
              end

              render :json => response
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def get_details
          if @user.party.business_party.is_a?(Individual)
            business_party = @user.party.business_party.to_json(:only => [:current_first_name, :current_last_name, :gender, :total_years_work_experience])
          else
            business_party = @user.party.business_party.to_json(:only => [:description])
          end

          render :inline => "{entityType:'#{@user.party.business_party.class.to_s}',
                              businessParty:#{business_party},
                              userInfo:#{@user.to_json(:only => [:username, :email, :last_login_at, :last_activity_at, :failed_login_count, :activation_state])}}"
        end

        def delete
          application = DesktopApplication.find_by_internal_identifier('user_management')
          if current_user.has_capability?(application, 'create', 'User')
            unless @user.party.nil?
              @user.party.destroy
            else
              @user.destroy
            end

            render :json => {:success => true}
          else
            render :json => {:success => false, :message => 'Invalid Access'}
          end
        end

        protected

        def get_user
          @user = User.find(params[:id])
        end
        
      end
    end
  end
end
