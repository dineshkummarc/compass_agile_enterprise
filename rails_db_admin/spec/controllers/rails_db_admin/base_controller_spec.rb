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
    end

    it "should return model, columns, and fields" do
      post :base, {:use_route => :rails_db_admin,
                   :action => "setup_table_grid",
                   :table =>  'role_types'}

      parsed_body = JSON.parse(response.body)
      parsed_body["model"].should eq("role_types")
      parsed_body["columns"].should include(
        {"header"=>"id", "type"=>"number", "dataIndex"=>"id", "width"=>150})
    end

    it "should return true even if there is not an 'id' column on the table in question" do

      post :base, {:use_route => :rails_db_admin,
                   :action => "setup_table_grid",
                   :table =>  'preference_options_preference_types'}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end

    it "should return model, columns, and fields even if there is not an 'id' column on a table 
        and should have a 'fake_id' column in the fields and columns array" do
      post :base, {:use_route => :rails_db_admin,
                   :action => "setup_table_grid",
                   :table =>  'preference_options_preference_types'}

      parsed_body = JSON.parse(response.body)
      parsed_body["model"].should eq("preference_options_preference_types")
      parsed_body["columns"][0].should include(
        {"header"=>"preference_type_id",
          "type"=>"number",
          "dataIndex"=>"preference_type_id",
          "width"=>150,
          "editor"=>{"xtype"=>"textfield"}})

      parsed_body["columns"][4].should include(
          {"header"=>"fake_id", "type"=>"number", "dataIndex"=>"fake_id", "hidden"=>true}
      )

      parsed_body["fields"].should include(
        {"name" => "preference_type_id"})
      parsed_body["fields"].should include(
        {"name" => "fake_id"})
    end

    it "should return a value called id_property that equals 'fake_id'" do
      post :base, {:use_route => :rails_db_admin,
                   :action => "setup_table_grid",
                   :table =>  'preference_options_preference_types'}

      parsed_body = JSON.parse(response.body)
      parsed_body["id_property"].should eq("fake_id")
    end

    it "should return a value called id_property that equals 'id'" do
      post :base, {:use_route => :rails_db_admin,
                   :action => "setup_table_grid",
                   :table =>  'role_types'}

      parsed_body = JSON.parse(response.body)
      parsed_body["id_property"].should eq("id")

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

    #TODO: Need to setup Factory Girl to dummy up data for this test
    it "should return successfully with a fake_id column because there is no id column defined in the DB" do
      get :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => 'preference_options_preference_types'}
      parsed_body = JSON.parse(response.body)
      parsed_body["totalCount"].should eq(0)
    end

  end


  describe "PUT table_data" do
    before(:each) do


      @pref_opt_types_data = {"preference_type_id" => "1",
                              "preference_option_id" => "2",
                              "created_at" => "2011-10-11 00:54:56.137144",
                              "updated_at" => "2011-10-11 00:54:56.137144"}

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


      RailsDbAdmin::TableSupport.should_receive(
        :new).and_return(@table_support)
      RailsDbAdmin::Extjs::JsonDataBuilder.should_receive(
        :new).and_return(@json_data_builder)

    end

    it "should return success" do

      @table_support.should_receive(:update_table).with(
        "role_types", "2", @mod_role_types_data)
      @json_data_builder.should_receive(:get_row_data).with(
        "role_types", "2").and_return(@role_types_data)

      put :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => "role_types",
                  :data => [@role_types_data, @role_types_data] }

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end

    it "should update table data and return success even if there is not an 'id' column" do

      @table_support.should_receive(:update_table_without_id).with(
        "preference_options_preference_types",  [@pref_opt_types_data, @pref_opt_types_data])

      @json_data_builder.should_receive(:get_row_data_no_id).with(
        "preference_options_preference_types", @pref_opt_types_data).and_return(
        @pref_opt_types_data)

      put :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => "preference_options_preference_types",
                  :data => [@pref_opt_types_data, @pref_opt_types_data]}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["data"].should eq(@pref_opt_types_data)
    end


  end

  describe "POST table_data" do
    before(:each) do
      @table_support = double("RailsDbAdmin::TableSupport")
      @json_data_builder = double("RailsDbAdmin::Extjs::JsonDataBuilder")


      RailsDbAdmin::TableSupport.should_receive(
        :new).and_return(@table_support)
      RailsDbAdmin::Extjs::JsonDataBuilder.should_receive(
        :new).and_return(@json_data_builder)

    end

    it "should return success and the row that was created" do
      @role_types_data = {"id" => 3,
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

      @mod_types_data = {"parent_id" => "",
                          "lft" => "3",
                          "rgt" => "4",
                          "description" => "Partner-Test",
                          "comments" => "",
                          "internal_identifier" => "partner",
                          "external_identifier" => "",
                          "external_id_source" => "",
                          "created_at" => "2011-10-11 00:54:56.137144",
                          "updated_at" => "2011-10-11 00:54:56.137144"}

      @table_support.should_receive(:insert_row).with("role_types", @mod_types_data).
        and_return(3)
      @json_data_builder.should_receive(:get_row_data).with("role_types",3).
        and_return(@role_types_data)

      post :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => "role_types",
                  :data => @role_types_data}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body[:data].should eq(@roles_types_data)
    end

    it "should return success even with empty row hashed passed in" do
      @role_types_data = {"id" => "",
                          "parent_id" => "",
                          "lft" => "",
                          "rgt" => "",
                          "description" => "",
                          "comments" => "",
                          "internal_identifier" => "",
                          "external_identifier" => "",
                          "external_id_source" => "",
                          "created_at" => "",
                          "updated_at" => ""}

      @mod_types_data = {"parent_id" => "",
                          "lft" => "",
                          "rgt" => "",
                          "description" => "",
                          "comments" => "",
                          "internal_identifier" => "",
                          "external_identifier" => "",
                          "external_id_source" => "",
                          "created_at" => "",
                          "updated_at" => ""}

      @table_support.should_receive(:insert_row).with("role_types", @mod_types_data).
        and_return(3)
      @json_data_builder.should_receive(:get_row_data).with("role_types",3).
        and_return(@role_types_data)

      post :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => "role_types",
                  :data => @role_types_data}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body[:data].should eq(@roles_types_data)
    end

    it "should return success and the inserted data, with a row with a 'fake_id'" do

      @pref_opt_types_data = {"preference_type_id" => "1",
                              "preference_option_id" => "2",
                              "created_at" => "2011-10-11 00:54:56.137144",
                              "updated_at" => "2011-10-11 00:54:56.137144",
                              "fake_id" => "5"}

      @mod_data = {"preference_type_id" => "1",
                              "preference_option_id" => "2",
                              "created_at" => "2011-10-11 00:54:56.137144",
                              "updated_at" => "2011-10-11 00:54:56.137144"}

      @final_data = {"preference_type_id" => "1",
                              "preference_option_id" => "2",
                              "created_at" => "2011-10-11 00:54:56.137144",
                              "updated_at" => "2011-10-11 00:54:56.137144",
                              "fake_id" => 300}

      @table_support.should_receive(:insert_row).with("preference_options_preference_types", @mod_data, true).and_return(300)

      @json_data_builder.should_receive(:get_row_data_no_id).with(
        "preference_options_preference_types", @mod_data).and_return(
        @pref_opt_types_data)

      post :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => "preference_options_preference_types",
                  :data => @pref_opt_types_data}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["data"].should eq(@final_data)
    end

    it "should return success and the inserted data, with a row with a 'fake_id', with empty data passed in" do

      @pref_opt_types_data = {"preference_type_id" => "",
                              "preference_option_id" => "",
                              "created_at" => "",
                              "updated_at" => "",
                              "fake_id" => ""}

      @mod_data = {"preference_type_id" => "",
                              "preference_option_id" => "",
                              "created_at" => "",
                              "updated_at" => ""}

      @final_data = {"preference_type_id" => "",
                              "preference_option_id" => "",
                              "created_at" => "",
                              "updated_at" => "",
                              "fake_id" => 300}

      @table_support.should_receive(:insert_row).with("preference_options_preference_types", @mod_data, true).and_return(300)

      @json_data_builder.should_receive(:get_row_data_no_id).with(
        "preference_options_preference_types", @mod_data).and_return(
        @pref_opt_types_data)

      post :base, {:use_route => :rails_db_admin,
                  :action => "table_data",
                  :table => "preference_options_preference_types",
                  :data => @pref_opt_types_data}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["data"].should eq(@final_data)
    end
  end


  describe "DELETE table_data" do

    it "should process the request successfully" do
      @table_support = double("RailsDbAdmin::TableSupport")
      RailsDbAdmin::TableSupport.should_receive(
        :new).and_return(@table_support)

      id = "2"

      @table_support.should_receive(:delete_row).with(
        "role_types", id)

      delete :base, {:use_route => :rails_db_admin,
                     :action => "table_data",
                     :table => "role_types",
                     :id => id}
    end


    it "should fail because we don't send an id parameter" do

      id = "2"
      @table_support = double("RailsDbAdmin::TableSupport")
      RailsDbAdmin::TableSupport.should_receive(
        :new).and_return(@table_support)
      @table_support.should_receive(:delete_row).with(
        "role_types", id).and_raise(ActiveRecord::StatementInvalid)


      delete :base, {:use_route => :rails_db_admin,
                     :action => "table_data",
                     :table => "role_types",
                     :id => id}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(false)
      parsed_body["exception"].should eq("Delete operation not supported on tables without an ID column")

    end

  end

  after(:all) do
    RoleType.where(:internal_identifier => "execute_query_test_role").destroy_all
    RoleType.where(:internal_identifier => "execute_query_test_role_2").destroy_all
  end
end
