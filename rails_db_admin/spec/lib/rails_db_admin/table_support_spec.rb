require "spec_helper"

describe RailsDbAdmin::TableSupport do

  before(:each) do
    @connection_class = double(ActiveRecord::Base)
    @adapter = double(ActiveRecord::ConnectionAdapters::AbstractAdapter)
  end

  describe "instance methods" do 
    before(:each) do
      @connection_class.should_receive(:connection).and_return(@adapter)
      @instance = RailsDbAdmin::TableSupport.new(@connection_class)
    end

    describe "update_table" do

      it "should be able to send a correctly formed SQL statment to the ConnectionAdapter" do

        @col = [ActiveRecord::ConnectionAdapters::Column.new("id",
                                                            "INTEGER",
                                                            false),
               ActiveRecord::ConnectionAdapters::Column.new("parent_id",
                                                            "integer",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("lft",
                                                            "integer",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("rgt",
                                                            "integer",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("description",
                                                            "varchar(255)",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("comments",
                                                            "varchar(255)",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("internal_identifier",
                                                            "varchar(255)",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("external_identifier",
                                                            "varchar(255)",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("external_id_source",
                                                            "varchar(255)",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("created_at",
                                                            "datetime",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("updated_at",
                                                            "datetime",
                                                            true)]

        @table = "role_types"
        data = {"parent_id" => "",
                            "lft" => "3",
                            "rgt" => "4",
                            "description" => "Partner-Test",
                            "comments" => "",
                            "internal_identifier" => "partner",
                            "external_identifier" => "",
                            "external_id_source" => "",
                            "created_at" => "2011-10-11 00:54:56.137144",
                            "updated_at" => "2011-10-11 00:54:56.137144"}


        @sql = "UPDATE \"role_types\" SET \"parent_id\" = NULL, \"lft\" = 3, "\
              "\"rgt\" = 4, \"description\" = 'Partner-Test', "\
              "\"comments\" = NULL, \"internal_identifier\" = 'partner', "\
              "\"external_identifier\" = NULL, \"external_id_source\" = NULL, "\
              "\"created_at\" = '2011-10-11 00:54:56.137144', "\
              "\"updated_at\" = '2011-10-11 00:54:56.137144' "\
              "WHERE \"role_types\".\"id\" = 5"

        @adapter.should_receive(:columns).with(@table).and_return(@col)
        @adapter.should_receive(:execute).with(@sql)
        @instance.update_table(@table, ["id","5"], data)
      end
    end

    describe "update_table_without_id" do

      it "should be able to send a correctly formed SQL statment to the ConnectionAdapter" do

        @col = [ActiveRecord::ConnectionAdapters::Column.new("preference_type_id",
                                                            "INTEGER",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("preference_option_id",
                                                            "integer",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("created_at",
                                                            "datetime",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("updated_at",
                                                            "datetime",
                                                            true)]

        @table = "preference_options_preference_types"

        @data = [{"preference_type_id" => "1",
                "preference_option_id" => "2",
                "created_at" => "2011-10-11 00:54:56.137144",
                "updated_at" => "2011-10-11 00:54:56.137144",
                "fake_id" => 1},
                {"preference_type_id" => 2,
                "preference_option_id" => 2,
                "created_at" => "",
                "updated_at" => "2011-10-11 00:54:56.137144",
                "fake_id" => 1}]

        @sql = "UPDATE \"preference_options_preference_types\" "\
              "SET \"preference_type_id\" = 1, \"created_at\" "\
              "= '2011-10-11 00:54:56.137144' WHERE "\
              "\"preference_options_preference_types\"."\
              "\"preference_type_id\" = 2 AND "\
              "\"preference_options_preference_types\"."\
              "\"preference_option_id\" = 2 AND "\
              "\"preference_options_preference_types\".\"created_at\" "\
              "IS NULL AND \"preference_options_preference_types\"."\
              "\"updated_at\" = '2011-10-11 00:54:56.137144'"\

        @adapter.should_receive(:columns).with(@table).and_return(@col)
        @adapter.should_receive(:execute).with(@sql)
        @instance.update_table_without_id(@table, @data)
      end
    end


    describe "insert_row" do

      it "should return an id" do

        @table = "role_types"

        mod_types_data = {"parent_id" => "",
                            "lft" => "3",
                            "rgt" => "4",
                            "description" => "Partner-Test",
                            "comments" => "",
                            "internal_identifier" => "partner",
                            "external_identifier" => "",
                            "external_id_source" => "",
                            "created_at" => "2011-10-11 00:54:56.137144",
                            "updated_at" => "2011-10-11 00:54:56.137144"}

        sql =  "INSERT INTO \"role_types\" (\"parent_id\", "\
               "\"lft\", \"rgt\", \"description\", "\
               "\"comments\", \"internal_identifier\", "\
               "\"external_identifier\", \"external_id_source\", "\
               "\"created_at\", \"updated_at\") "\
               "VALUES (NULL, 3, 4, 'Partner-Test', NULL, "\
               "'partner', NULL, NULL, '2011-10-11 00:54:56.137144', "\
               "'2011-10-11 00:54:56.137144')"

        @col = [ActiveRecord::ConnectionAdapters::Column.new("id",
                                                            "INTEGER",
                                                            false),
               ActiveRecord::ConnectionAdapters::Column.new("parent_id",
                                                            "integer",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("lft",
                                                            "integer",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("rgt",
                                                            "integer",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("description",
                                                            "varchar(255)",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("comments",
                                                            "varchar(255)",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("internal_identifier",
                                                            "varchar(255)",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("external_identifier",
                                                            "varchar(255)",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("external_id_source",
                                                            "varchar(255)",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("created_at",
                                                            "datetime",
                                                            true),
               ActiveRecord::ConnectionAdapters::Column.new("updated_at",
                                                            "datetime",
                                                            true)]

        @adapter.should_receive(:insert).with(sql).and_return(30)
        @adapter.should_receive(:columns).with(@table).and_return(@col)

        returned = @instance.insert_row("role_types",mod_types_data)
        returned.should eq(30)
      end

      it "should return a fake_id" do

        @table = "preference_options_preference_types"

        @data = {"preference_type_id" => "1",
                "preference_option_id" => "2",
                "created_at" => "2011-10-11 00:54:56.137144",
                "updated_at" => "2011-10-11 00:54:56.137144"
                }

        @sql =  "INSERT INTO \"preference_options_preference_types\" "\
                "(\"preference_type_id\", \"preference_option_id\", "\
                "\"created_at\", \"updated_at\") VALUES "\
                "(1, 2, '2011-10-11 00:54:56.137144', "\
                "'2011-10-11 00:54:56.137144')"

        @adapter.should_receive(:insert).with(@sql).and_return(nil)

        returned = @instance.insert_row(@table, @data, true)
        returned.should > 100
        returned.should < 501
      end
    end

    describe "delete_row" do

      it "should produce valid delete sql" do

        @sql = "DELETE FROM \"some_table\" WHERE \"some_table\".\"id\" = 3"
        @adapter.should_receive(:execute).with(@sql)
        @instance.delete_row("some_table", ['id', 3])
      end
    end

    describe "primary_key" do

      it "should return an array with the name of the primary key and a nil" do
        @adapter.should_receive(:primary_key).with("role_types").
          and_return("id")
        @returned = @instance.primary_key("role_types")

        @returned.should eq(["id",nil])
      end

    end

    describe "primary_key?" do

      it "should return true because table supports a primary key" do

        @table = "role_types"
        @adapter.should_receive(:supports_primary_key?).and_return(true)
        @adapter.should_receive(:primary_key).with(@table).
          and_return("id")
        @returned = @instance.primary_key?(@table)

        @returned.should eq(true)
      end

      it "should return false because this table doesn't support a primary key" do

        @table = "some_table"
        @adapter.should_receive(:supports_primary_key?).and_return(true)
        @adapter.should_receive(:primary_key).with(@table).
          and_return(nil)
        @returned = @instance.primary_key?(@table)

        @returned.should eq(false)
      end

      it "should return false because the db doesn't support primary keys" do

        @table = "some_table"
        @adapter.should_receive(:supports_primary_key?).and_return(false)
        @returned = @instance.primary_key?(@table)

        @returned.should eq(false)
      end

    end

    describe "clean_nulls" do

      before(:each) do
        @connection_class = RailsDbAdmin::ConnectionHandler.create_connection_class("spec")
        @instance = RailsDbAdmin::TableSupport.new(@connection_class)
        @data_hash = {"description" => "",
                      "parent_id" => 0,
                      "id" => 0}
      end

      it "if a column is nullable, should convert \"\" to nil" do 

        @table = "role_types"
        @instance.clean_nulls!(@table, @data_hash)
        @data_hash["description"].should eq(nil)
      end

      it "if a column is nullable, should convert 0 to NULL" do

        @table = "role_types"
        @instance.clean_nulls!(@table, @data_hash)
        @data_hash["parent_id"].should eq(nil)
      end

      it "if a column is not nullable, leave \"\" as \"\""

      it "if a column is not nullable, leave 0 as 0" do

        @table = "role_types"
        @instance.clean_nulls!(@table, @data_hash)
        @data_hash["id"].should eq(0)
      end

    end
  end

  describe "static methods" do

    describe "add_fake_id_col" do

      it "should return an array of hashes, where each hash has a fake_id column" do

        data = [{:preference_type_id => "1",
                :preference_option_id => "2",
                :created_at => "2011-10-11 00:54:56.137144",
                :updated_at => "2011-10-11 00:54:56.137144"},
                {:preference_type_id => "2",
                :preference_option_id => "2",
                :created_at => "2011-10-11 00:54:56.137144",
                :updated_at => "2011-10-11 00:54:56.137144"}]

        result = {:fake_id => 1,
                :preference_type_id => "1",
                :preference_option_id => "2",
                :created_at => "2011-10-11 00:54:56.137144",
                :updated_at => "2011-10-11 00:54:56.137144"}
        result2 = {:fake_id => 2,
                :preference_type_id => "2",
                :preference_option_id => "2",
                :created_at => "2011-10-11 00:54:56.137144",
                :updated_at => "2011-10-11 00:54:56.137144"}


        returned = RailsDbAdmin::TableSupport.add_fake_id_col(data)
        returned[0].should include(result)
        returned[1].should include(result2)
      end
    end
  end
end



