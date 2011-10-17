require "spec_helper"

describe RailsDbAdmin::QueriesController do

  describe "POST execute_query" do

    before(:all) do 
      Factory.create(:role_type, :internal_identifier => "execute_query_test_role")
    end

    before(:each) do
      basic_user_auth
    end

    it "returns unsuccessful because of an empty result set" do
      post :queries, {:use_route => :rails_db_admin, :action => "execute_query",
                      :cursor_pos => "0",:sql => "SELECT * FROM relationship_types;"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(false)
      parsed_body["exception"].should eq("Empty result set")
    end

    it "should not throw exception if there is 1 statement and no semi-colon" do
      post :queries, {:use_route => :rails_db_admin, :action => "execute_query",
                      :cursor_pos => "0", :sql => "SELECT * FROM role_types WHERE internal_identifier = 'execute_query_test_role'"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end

    after(:all) do
      RoleType.where(:internal_identifier => "execute_query_test_role").destroy_all
    end

  end
end
