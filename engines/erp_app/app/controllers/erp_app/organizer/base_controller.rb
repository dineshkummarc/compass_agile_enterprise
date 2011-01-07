class ErpApp::Organizer::BaseController < ErpApp::ApplicationController
  before_filter :login_required
  
  def login_path
    return organizer_login_path
  end

  def index
    @organizer = ::Organizer.find_by_user(current_user)
  end

end
