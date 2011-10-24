require "spec_helper"

describe RailsDbAdmin::Extjs::JsonDataBuilder do
  #preconditions
  before(:each) do
    @connection_class = double(ActiveRecord::Base)
    @adapter = double(ActiveRecord::ConnectionAdapters::AbstractAdapter)
    @connection_class.should_receive(:connection).and_return(@adapter)
    @instance = RailsDbAdmin::Extjs::JsonDataBuilder.new(@connection_class)

  end

  describe "build_json_data" do
    before(:each) do

    end

    it "should pass well-formed sql to the connection.select_all" do

      options = {:table  => "test_table",
                 :offset => 2,
                 :limit  => 30,
                 :order  => 'id desc'}

      sql = "SELECT  * FROM \"test_table\"  ORDER BY id desc LIMIT 30 OFFSET 2"

      @instance.should_receive(:get_total_count).and_return(25)

      @adapter.should_receive(:select_all).with(sql).and_return([])

      @adapter.should_receive(:sanitize_limit).with(30).and_return(30)

      RailsDbAdmin::TableSupport.should_receive(
        :database_rows_to_hash).with([]).and_return([])

      @instance.build_json_data(options)
    end

    it "should pass well-formed sql to the connection.select_all (string args)" do

      options = {:table  => "test_table",
                 :offset => "2",
                 :limit  => "30",
                 :order  => 'id desc'}

      sql = "SELECT  * FROM \"test_table\"  ORDER BY id desc LIMIT 30 OFFSET 2"
      @adapter.should_receive(:select_all).with(sql).and_return([])

      @adapter.should_receive(:sanitize_limit).with("30").and_return(30)

      RailsDbAdmin::TableSupport.should_receive(
        :database_rows_to_hash).with([]).and_return([])

      @instance.should_receive(:get_total_count).and_return(25)

      @instance.build_json_data(options)
    end

    it "should create well-formed sql, only passing :limit, :order options" do

      options = {:table => "test_table",
                 :limit => 30,
                 :order => 'id desc'}

      sql = "SELECT  * FROM \"test_table\"  ORDER BY id desc LIMIT 30"
      @adapter.should_receive(:select_all).with(sql).and_return([])

      @adapter.should_receive(:sanitize_limit).with(30).and_return(30)

      RailsDbAdmin::TableSupport.should_receive(
        :database_rows_to_hash).with([]).and_return([])

      @instance.should_receive(:get_total_count).and_return(25)

      @instance.build_json_data(options)

    end

    it "should create well-formed sql, only passing :limit option" do

      options = {:table => "test_table",
                 :limit => 30}

      sql = "SELECT  * FROM \"test_table\"  LIMIT 30"
      @adapter.should_receive(:select_all).with(sql).and_return([])

      @adapter.should_receive(:sanitize_limit).with(30).and_return(30)

      @instance.should_receive(:get_total_count).and_return(25)

      RailsDbAdmin::TableSupport.should_receive(
        :database_rows_to_hash).with([]).and_return([])

      @instance.build_json_data(options)

    end

    it "should create well-formed sql, only passing :order option" do

      options = {:table => "test_table",
                 :order => "id asc"}

      sql = "SELECT * FROM \"test_table\"  ORDER BY id asc"
      @adapter.should_receive(:select_all).with(sql).and_return([])

      RailsDbAdmin::TableSupport.should_receive(
        :database_rows_to_hash).with([]).and_return([])

      @instance.should_receive(:get_total_count).and_return(25)

      @instance.build_json_data(options)

    end

    it "should create well-formed sql, only passing :table option" do

      options = {:table => "test_table"}

      sql = "SELECT * FROM \"test_table\" "
      @adapter.should_receive(:select_all).with(sql).and_return([])

      RailsDbAdmin::TableSupport.should_receive(
        :database_rows_to_hash).with([]).and_return([])

      @instance.should_receive(:get_total_count).and_return(25)

      @instance.build_json_data(options)

    end

    it "should raise an exception if missing :table option" do

      options = {:limit => 30}

      expect {@instance.build_json_data(options) }.to raise_error

    end

    it "should call add_fake_id_col if there's no 'id' col in the result hash" do

      options = {:table => "test_table",
                 :start => 0,
                 :limit => 30,
                 :order => 'id desc'}

      sql = "SELECT  * FROM \"test_table\"  ORDER BY id desc LIMIT 30"
      @adapter.should_receive(:select_all).with(sql).and_return([])

      test_data = [{"column_a" => "blah1", "column_b" => "blah2"},
                   {"column_a" => "blah3", "column_b" => "blah4"}]

      @adapter.should_receive(:sanitize_limit).with(30).and_return(30)

      RailsDbAdmin::TableSupport.should_receive(
        :database_rows_to_hash).with([]).and_return(test_data)

      RailsDbAdmin::TableSupport.should_receive(:add_fake_id_col).with(
        test_data).and_return(test_data)

      @instance.should_receive(:get_total_count).and_return(25)

      @instance.build_json_data(options)
    end

  end

  describe "get_row_data_no_id" do

    it "should return a row with a fake_id column added to it" do

      @table = "preference_options_preference_types"

      row_hash = {"preference_type_id" => "1",
                  "preference_option_id" => "2",
                  "created_at" => "2011-10-11 00:54:56.137144",
                  "updated_at" => "2011-10-11 00:54:56.137144"}

      @result = {:preference_type_id => "1",
                 :preference_option_id => "2",
                 :created_at => "2011-10-11 00:54:56.137144",
                 :updated_at => "2011-10-11 00:54:56.137144",
                 :fake_id => 1}

      @rows = [{"preference_type_id" => "1",
                  "preference_option_id" => "2",
                  "created_at" => "2011-10-11 00:54:56.137144",
                  "updated_at" => "2011-10-11 00:54:56.137144"}]

      @sql = "SELECT * FROM preference_options_preference_types "\
             "WHERE 1=1 AND preference_type_id = '1' "\
             "AND preference_option_id = '2' "\
             "AND created_at = '2011-10-11 00:54:56.137144' "\
             "AND updated_at = '2011-10-11 00:54:56.137144' "

      @col = [ActiveRecord::ConnectionAdapters::Column.new("preference_type_id", "INTEGER"),
             ActiveRecord::ConnectionAdapters::Column.new("preference_option_id", "INTEGER"),
             ActiveRecord::ConnectionAdapters::Column.new("created_at", "datetime"),
             ActiveRecord::ConnectionAdapters::Column.new("updated_at", "datetime")]

      @adapter.should_receive(:columns).with(@table).and_return(@col)
      @adapter.should_receive(:select_all).with(@sql).and_return(@rows)

      returns = @instance.get_row_data_no_id("preference_options_preference_types", row_hash)

      returns.should eq(@result)

    end




  end

end
