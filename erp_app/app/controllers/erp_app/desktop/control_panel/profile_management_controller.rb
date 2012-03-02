module ErpApp
	module Desktop
		module ControlPanel
			class ProfileManagementController < ErpApp::Desktop::ControlPanel::BaseController
			  def update_password

          if user = User.authenticate(current_user.username, params[:old_password])
            user.password_confirmation = params[:password_confirmation]
            if user.change_password!(params[:password])
              response = {:success => true}
            else
              #### validation failed ####
              response = {:success => false, :message => 'Error updating password.'}
            end
          else
            message = "Invalid current password."
            response = {:success => false, :message => message}
          end

          render :json => response
			  end
			  
			  def update_email
			  	  current_user.email = params[:email]
			  	  if current_user.save
			  	  	  message = "<ul>"
			  	  	  current_user.errors.collect do |e, m|
			  	  	  	  message << "<li>#{e} #{m}</li>"
			  	  	  end
			  	  	  message << "</ul>"
			  	  	  render :json => {:success => true, :message => message}
			  	  else
			  	  	  render :json => {:success => true, :message => 'Error updating email'}
			  	  end

			  end
			end
		end
	end
end
