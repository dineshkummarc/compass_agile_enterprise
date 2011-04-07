require 'uri'

class Tenancy::RedirectController < ActionController::Base
  def index
    route = URI.unescape(params[:route])
    redirect_to route
  end
end