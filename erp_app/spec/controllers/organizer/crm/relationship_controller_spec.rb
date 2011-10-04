require "spec_helper"

describe ErpApp::Organizer::Crm::RelationshipController do
  include Devise::TestHelpers

  before (:each) do
    #calls a function sets up basic user auth so devise won't cause
    #our controller tests to fail
    basic_user_auth
  end

  describe "GET index" do
    it "has a 200 status code" do
      get :index, {:use_route => :erp_app, :party_id => 1}
      #puts @response
      response.code.should eq("200")
    end
  end

end

