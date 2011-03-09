class LoginController < BaseController
  def index
    @redirect_to = '/'
    unless session[:refered_from].blank?
      @redirect_to = session[:refered_from]
    end
  end

  #no section to set
  def set_section
    return false
  end
end
