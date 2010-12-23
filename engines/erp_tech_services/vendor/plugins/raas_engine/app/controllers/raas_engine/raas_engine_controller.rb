class RaasEngineController < ApplicationController
  layout("raas_engine/layouts/raas_engine_application")
  unless ActionController::Base.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, ActionController::UnknownController, ActionController::UnknownAction, :with => :render_404
    rescue_from RuntimeError, :with => :render_500
  end

  def index
  end

  protected

  private

  def render_404
    render :template => "/rescues/404", :layout => "raas_engine_application", :status => :not_found
  end

  def render_500
    render :template => "/rescues/500", :layout => "raas_engine_application", :status => :internal_server_error
  end
end