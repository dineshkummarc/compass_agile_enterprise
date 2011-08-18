module ErpApp
	module Desktop
		module ControlPanel
			class ProfileManagementController < ErpApp::Desktop::ControlPanel::BaseController
			  def update_password
				user = current_user
				unless user.valid_password?(params[:old_password])
				  message = "Invalid current password."
				  response = {:success => false, :message => message}
				else
				  user.password = params[:password]
				  user.password_confirmation = params[:password_confirmation]
				  user.save
				  if user.errors.empty?
					response = {:success => true}
				  else
					message = "<ul>"
					user.errors.collect do |e, m|
					  message << "<li>#{e.humanize unless e == "base"} #{m}</li>"
					end
					message << "</ul>"
					response = {:success => false, :message => message}
				  end
				end

				render :inline => response.to_json
			  end
			end
		end
	end
end
