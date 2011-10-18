require "spec_helper"

describe RailsDbAdmin::BaseController do

  #handle devise user auth
  before(:each) do
    basic_user_auth
  end

  before(:all) do 
    Factory.create(:role_type, :internal_identifier => "execute_query_test_role")
    Factory.create(:role_type, :internal_identifier => "execute_query_test_role_2")
  end

  describe "POST setup_table_grid" do

    it "should return success:true" do

      post :base, {:use_route => :rails_db_admin,
                   :action => "setup_table_grid",
                   :table =>  'role_types'}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["model"].should eq("role_types")
      parsed_body["columns"].should include({"header"=>"id", "type"=>"number", "dataIndex"=>"id", "width"=>150})
    end


  end


  describe "GET table_data" do

    it "should return JSON to display in an ExtJS data grid for Rails tables with an Id column" do
      get :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => "role_types"}

      parsed_body = JSON.parse(response.body)
      parsed_body["totalCount"].should eq(2)
    end

    it "should return 1 row because start is increased by 1, but totalCount should remain 2" do
      get :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => "role_types",
                  :start => "1"}

      parsed_body = JSON.parse(response.body)
      parsed_body["totalCount"].should eq(2)
      parsed_body["data"].length.should eq(1)
    end

    it "should return 1 row because limit is set to 1, but totalCount should remain 2" do

      get :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => "role_types",
                  :limit => "1"}

      parsed_body = JSON.parse(response.body)
      parsed_body["totalCount"].should eq(2)
      parsed_body["data"].length.should eq(1)
    end

  end


  describe "PUT table_data" do
    before(:each) do
      @role_types_data = {"id" => 2,
                          "parent_id" => "",
                          "lft" => "3",
                          "rgt" => "4",
                          "description" => "Partner-Test",
                          "comments" => "",
                          "internal_identifier" => "partner",
                          "external_identifier" => "",
                          "external_id_source" => "",
                          "created_at" => "2011-10-11 00:54:56.137144",
                          "updated_at" => "2011-10-11 00:54:56.137144"}

      @mod_role_types_data = {"parent_id" => "",
                              "lft" => "3",
                              "rgt" => "4",
                              "description" => "Partner-Test",
                              "comments" => "",
                              "internal_identifier" => "partner",
                              "external_identifier" => "",
                              "external_id_source" => "",
                              "created_at" => "2011-10-11 00:54:56.137144",
                              "updated_at" => "2011-10-11 00:54:56.137144"}

      @table_support = double("RailsDbAdmin::TableSupport")
      @json_data_builder = double("RailsDbAdmin::Extjs::JsonDataBuilder")

      @table_support.should_receive(:update_table).with(
        "role_types", "2", @mod_role_types_data)
      @json_data_builder.should_receive(:get_row_data).with(
        "role_types", "2").and_return(@role_types_data)

      RailsDbAdmin::TableSupport.should_receive(
        :new).and_return(@table_support)
      RailsDbAdmin::Extjs::JsonDataBuilder.should_receive(
        :new).and_return(@json_data_builder)

    end

    it "should return success" do

      put :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => "role_types",
                  :data => @role_types_data }
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end

  end

  after(:all) do
    RoleType.where(:internal_identifier => "execute_query_test_role").destroy_all
    RoleType.where(:internal_identifier => "execute_query_test_role_2").destroy_all
  end
end
