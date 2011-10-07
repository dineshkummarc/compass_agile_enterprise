require "spec_helper"

describe ErpApp::Organizer::Crm::RelationshipController do

  describe "GET index" do

    before(:each) do
      basic_user_auth

    end

    it "has a 200 status code" do
      get :index, {:use_route => :erp_app, :party_id => 1, :relationship_type => "customer_of_partner"}
      response.code.should eq("200")
    end

    it "throw ActiveRecord::RecordNotFound when no party id passed" do
      expect { get :index, {:use_route => :erp_app} }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should return a successful response even if there are no relationships" do
      get :index, {:use_route => :erp_app, :party_id => 1, :relationship_type => "customer_of_partner"}
      response.should be_success
    end

    it "has a relationship count == 2" do

      #for some reason I had to use Factory's instead of Rspec doubles because of a method call
      #on this object in the controller
      relationships = [Factory.build(:party_relationship), Factory.build(:party_relationship)]

      #Since find_relationships_by_type is an instance method, need to mock a instance of 
      #Party and then spec the return value for the above method
      @party = double("Party")
      @party.should_receive(:find_relationships_by_type).and_return(relationships)
      Party.should_receive(:find).and_return(@party)

      get :index, {:use_route => :erp_app, :party_id => 1, :relationship_type => "customer_of_partner"}

      #I want to evaluate the returned JSON, so parse it.
      parsed_body = JSON.parse(response.body)
      parsed_body["totalCount"].should eq(2)
    end

  end

end

