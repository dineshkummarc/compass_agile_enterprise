require "spec_helper"

describe RailsDbAdmin::ErpApp::Desktop::QueriesController do

  #handle devise user auth
  before(:each) do
    basic_user_auth
  end

  describe "POST execute_query" do

    before(:all) do 
      Factory.create(:role_type, :internal_identifier => "execute_query_test_role")
    end

    it "returns unsuccessful because of an empty result set" do

      post :queries, {:use_route => :rails_db_admin, :action => "execute_query",
                      :cursor_pos => "0",:sql => "SELECT * FROM relationship_types;"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(false)
      parsed_body["exception"].should eq("Empty result set")
    end

    it "should not throw exception if there is 1 statement and no semi-colon" do

      post :queries, {:use_route => :rails_db_admin,
                      :action => "execute_query",
                      :cursor_pos => "0",
                      :sql => "SELECT * FROM role_types "\
                              "WHERE internal_identifier"\
                              " = 'execute_query_test_role'"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end

    it "should work on multi-line queries" do

      post :queries, {:use_route => :rails_db_admin, :action => "execute_query",
                      :cursor_pos => "1",
                      :sql => "SELECT * FROM role_types \n"\
                              "WHERE internal_identifier ="\
                              "'execute_query_test_role';"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["exception"].should eq(nil)
    end

    it "should work on queries with line count >2" do 
      @sql = "DELETE%20FROM%20preference_options_preference_types"\
        "%20WHERE%20%0Apreference_type_id%20%3D%203%20AND%20%0"\
        "Apreference_option_id%20%3D%209%20OR%0Apreference_option_id"\
        "%20%3D%2010%3B%0A%0ASELECT%20*%20FROM%20preference_"\
        "options_preference_types%0AORDER%20BY%20preference_type_id%20ASC%3B"

      @sql = CGI::unescape(@sql)
      @cursor_pos = "6"

      post :queries, {:use_route => :rails_db_admin, :action => "execute_query",
                      :cursor_pos => @cursor_pos,
                      :sql => @sql}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end

    it "should work on input of multiple queries spanning several lines each " do

      post :queries, {:use_route => :rails_db_admin, :action => "execute_query",
                      :cursor_pos => "1",
                      :sql => "SELECT * FROM role_types \n"\
                              "WHERE internal_identifier = 'execute_query_test_role';\n"\
                              "SELECT * FROM widgets"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["exception"].should eq(nil)
    end

    after(:all) do
      RoleType.where(:internal_identifier => "execute_query_test_role").destroy_all
    end

  end

  describe "POST open_and_execute_query" do

    it "should return success" do

      @db_connection_class =
        RailsDbAdmin::ConnectionHandler.create_connection_class("spec")
      @query_support = double("RailsDbAdmin::QuerySupport")
      @query_support.should_receive(:get_query).and_return("SELECT 1 FROM dual;")
      columns = ["columns_a", "columns_b", "columns_c"]
      values = ["A", "B", "C"]

      @query_support.should_receive(:execute_sql).and_return([columns, values, nil])
      RailsDbAdmin::QuerySupport.should_receive(:new).and_return(@query_support)

      post :queries, {:use_route => :rails_db_admin,
                      :action => "open_and_execute_query",
                      :query_name => "some_query"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end

  describe "POST select_top_fifty" do


    it "should return true, a sql statement, grid columns & fields, and data" do

      post :queries, {:use_route => :rails_db_admin,
                      :action => "select_top_fifty",
                      :table => "role_types"}

      expected_sql = "SELECT  * FROM \"role_types\"  LIMIT 50"

      expected_column = {"header"=>"id", "type"=>"number",
                         "dataIndex"=>"id", "width"=>150}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["sql"].should eq(expected_sql)
      parsed_body["columns"][0].should include(expected_column)
      parsed_body["fields"][0].should include({"name"=>"id"})
    end
  end
end
