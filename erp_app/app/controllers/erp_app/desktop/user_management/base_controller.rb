module ErpApp
	module Desktop
		module UserManagement
			class BaseController < ErpApp::Desktop::BaseController
			  before_filter :get_user, :only => [:get_details, :update_user_password, :delete]

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

          ignored_params = %w{action controller gender}

          options = params
          gender = options[:gender]
          options.delete_if{|k,v| ignored_params.include?(k.to_s)}
          user = User.new(
            :email => params[:email],
            :username => params[:username],
            :password => params[:password],
            :password_confirmation => params[:password_confirmation]
          )

          if user.valid?
            individual = Individual.create(:gender => gender, :current_first_name => params[:first_name], :current_last_name => params[:last_name])
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

			  def get_details
          entity_info = nil
          if @user.party.business_party.is_a?(Individual)
            business_party = @user.party.business_party.to_json(:only => [:current_first_name, :current_last_name, :gender, :total_years_work_experience])
          else
            business_party = @user.party.business_party.to_json(:only => [:description])
          end

          render :inline => "{entityType:'#{@user.party.business_party.class.to_s}', 
                              businessParty:#{business_party},
                              userInfo:#{@user.to_json(:only => [:username, :email, :last_sign_in_at, :sign_in_count])}}"
			  end

			  def update_user_password
          @user.password = params[:password]
          @user.password_confirmation = params[:password_confirmation]
          @user.save
          if @user.errors.empty?
            response = {:success => true}
          else
            message = "<ul>"
            @user.errors.collect do |e, m|
              message << "<li>#{e} #{m}</li>"
            end
            message << "</ul>"
            response = {:success => false, :message => message}
          end

          render :json => response
			  end

			  def delete
          unless @user.party.nil?
            @user.party.destroy
          else
            @user.destroy
          end

          render :json => {:success => true}
			  end

			  private

			  def get_user
          @user = User.find(params[:id])
			  end
        
			end
		end
	end
end
