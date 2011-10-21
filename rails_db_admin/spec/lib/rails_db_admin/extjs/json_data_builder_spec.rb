require "spec_helper"

describe RailsDbAdmin::Extjs::JsonDataBuilder do
  before(:each) do
    @connection_class = double(ActiveRecord::Base)
    @adapter = double(ActiveRecord::ConnectionAdapters::AbstractAdapter)
    @connection_class.should_receive(:connection).and_return(@adapter)
    @instance = RailsDbAdmin::Extjs::JsonDataBuilder.new(@connection_class)
  end

  describe "build_json_data" do
    it "should pass well-formed sql to the connection.select_all" do
      options = {:table => "test_table",
                 :start => 0,
                 :limit => 30,
                 :order => 'id desc'}
      sql = "SELECT * FROM test_table order by id desc LIMIT 30"

      @instance.should_receive(:get_total_count).and_return(25)
      @adapter.should_receive(:add_limit_offset!).with(
        "SELECT * FROM test_table order by id desc",
        :limit => 30, :order=>"id desc").and_return(sql)

      @adapter.should_receive(:select_all).with(sql).and_return([])

      RailsDbAdmin::TableSupport.should_receive(
        :database_rows_to_hash).with([]).and_return([])

      @instance.build_json_data(options)
    end

    it "should call add_fake_id_col if there's no 'id' col in the result hash" do
      options = {:table => "test_table",
                 :start => 0,
                 :limit => 30,
                 :order => 'id desc'}
      sql = "SELECT * FROM test_table order by id desc LIMIT 30"

      test_data = [{"column_a" => "blah1", "column_b" => "blah2"},
                   {"column_a" => "blah3", "column_b" => "blah4"}]

      @instance.should_receive(:get_total_count).and_return(25)
      @adapter.should_receive(:add_limit_offset!).with(
        "SELECT * FROM test_table order by id desc",
        :limit => 30, :order=>"id desc").and_return(sql)

      @adapter.should_receive(:select_all).with(sql).and_return([])

      RailsDbAdmin::TableSupport.should_receive(
        :database_rows_to_hash).with([]).and_return(test_data)
      RailsDbAdmin::TableSupport.should_receive(:add_fake_id_col).with(
        test_data).and_return(test_data)
      @instance.build_json_data(options)
    end

  end

  describe "get_row_data_no_id" do

  end


end
