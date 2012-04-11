module ErpApp
	module Mobile
    module UserManagement
      class BaseController < ::ErpApp::Mobile::BaseController
        def index
          @application = MobileApplication.find_by_internal_identifier('user_management')
        end

        def users
          users = User.all.collect do |user|
            user.to_hash(:only => [:username, :email, :failed_logins_count, :activation_state],
              :additional_values => {
                :last_login_at => (user.last_login_at.nil? ? nil : user.last_login_at.to_time.strftime("%Y-%m-%dT%I:%M:%S")),
                :last_activity_at => (user.last_activity_at.nil? ? nil : user.last_activity_at.to_time.strftime("%Y-%m-%dT%I:%M:%S"))
              })
          end

          render :json => {:success => true, :users => users}
        end

      end
    end
  end
end