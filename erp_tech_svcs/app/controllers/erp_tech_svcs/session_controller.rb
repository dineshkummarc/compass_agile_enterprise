module ErpTechSvcs
  class SessionController < ActionController::Base
    def create
      last_login_at = nil
      potential_user = User.where('username = ? or email = ?', params[:login], params[:login]).first
      last_login_at = potential_user.last_login_at unless potential_user.nil?
        if login(params[:login],params[:password])
          login_to = last_login_at.nil? ? params[:first_login_to] : params[:login_to]
          login_to = login_to || params[:login_to]
          request.xhr? ? (render :json => {:success => true, :login_to => login_to}) : (redirect_to login_to)
        else
          message = "Login failed. Try again"
          flash[:notice] = message
          request.xhr? ? (render :json => {:success => false, :errors => {:reason => message}}) : (render :text => message)
        end
    end

    def destroy
      logout
      login_url = params[:login_url].blank? ? ErpTechSvcs::Config.login_url : params[:login_url]
      redirect_to login_url, :notice => "You have successfully logged out."
    end
  end#SessionsController
end#ErpTechSvcs