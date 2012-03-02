require "spec_helper"

describe RailsDbAdmin::Extjs::JsonColumnBuilder do

  before(:each) do
    @connection_class = RailsDbAdmin::ConnectionHandler.create_connection_class("spec")
    @connection = @connection_class.connection
  end

  describe "build_grid_columns" do

    it "should return an array of hashes to setup a ExtJS Grid column object" do

      expected_result =[{:header=>"id", :type=>"number", :dataIndex=>"id", :width=>150
                        },
                        {:header=>"parent_id",
                         :type=>"number",
                         :dataIndex=>"parent_id",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"lft",
                         :type=>"number",
                         :dataIndex=>"lft",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"rgt",
                         :type=>"number",
                         :dataIndex=>"rgt",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"description",
                         :type=>"string",
                         :dataIndex=>"description",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"comments",
                         :type=>"string",
                         :dataIndex=>"comments",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"internal_identifier",
                         :type=>"string",
                         :dataIndex=>"internal_identifier",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"external_identifier",
                         :type=>"string",
                         :dataIndex=>"external_identifier",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"external_id_source",
                         :type=>"string",
                         :dataIndex=>"external_id_source",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"created_at",
                         :type=>"date",
                         :dataIndex=>"created_at",
                         :width=>150
                        },
                        {:header=>"updated_at",
                         :type=>"date",
                         :dataIndex=>"updated_at",
                         :width=>150
                        }]

      result = RailsDbAdmin::Extjs::JsonColumnBuilder.build_grid_columns(
        @connection.columns("role_types"))

      result.should eq(expected_result)
    end

    it "should add a fake_id column to the result if I pass true as the second param" do

      expected_result =[{:header=>"id",
                         :type=>"number",
                         :dataIndex=>"id",
                         :width=>150},
                        {:header=>"parent_id",
                         :type=>"number",
                         :dataIndex=>"parent_id",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"lft",
                         :type=>"number",
                         :dataIndex=>"lft",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"rgt",
                         :type=>"number",
                         :dataIndex=>"rgt",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"description",
                         :type=>"string",
                         :dataIndex=>"description",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"comments",
                         :type=>"string",
                         :dataIndex=>"comments",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"internal_identifier",
                         :type=>"string",
                         :dataIndex=>"internal_identifier",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"external_identifier",
                         :type=>"string",
                         :dataIndex=>"external_identifier",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"external_id_source",
                         :type=>"string",
                         :dataIndex=>"external_id_source",
                         :width=>150,
                         :editor=>{:xtype=>"textfield"}
                        },
                        {:header=>"created_at",
                         :type=>"date",
                         :dataIndex=>"created_at",
                         :width=>150
                        },
                        {:header=>"updated_at",
                         :type=>"date",
                         :dataIndex=>"updated_at",
                         :width=>150
                        },
                        {:header=>"fake_id",
                         :type=>"number",
                         :dataIndex=>"fake_id",
                         :hidden=>true}]

      result = RailsDbAdmin::Extjs::JsonColumnBuilder.build_grid_columns(
        @connection.columns("role_types"), true)

      result.should eq(expected_result)
    end

  end

  describe "build_store_fields" do

    it "should return an array of hashes that will setup the fields config for an ExtJS grid" do

      expected_result = [{:name=>"id"},
                         {:name=>"parent_id"},
                         {:name=>"lft"},
                         {:name=>"rgt"},
                         {:name=>"description"},
                         {:name=>"comments"},
                         {:name=>"internal_identifier"},
                         {:name=>"external_identifier"},
                         {:name=>"external_id_source"},
                         {:name=>"created_at"},
                         {:name=>"updated_at"}]

      result = RailsDbAdmin::Extjs::JsonColumnBuilder.build_store_fields(
        @connection.columns("role_types"))

      result.should eq(expected_result)

    end

    it "should add a fake_id field to the result if I pass true as the second param" do

      expected_result = [{:name=>"id"},
                         {:name=>"parent_id"},
                         {:name=>"lft"},
                         {:name=>"rgt"},
                         {:name=>"description"},
                         {:name=>"comments"},
                         {:name=>"internal_identifier"},
                         {:name=>"external_identifier"},
                         {:name=>"external_id_source"},
                         {:name=>"created_at"},
                         {:name=>"updated_at"},
                         {:name=>"fake_id"}]

      result = RailsDbAdmin::Extjs::JsonColumnBuilder.build_store_fields(
        @connection.columns("role_types"),true)

      result.should eq(expected_result)

    end

  end


end
