require "spec_helper"

describe RailsDbAdmin::TableSupport do
  before(:each) do
    #@connection_handler = double(RailsDbAdmin::ConnectionHandler)
    #@conneciton_handler.should_receive(:create_connection_class).and_return(@db_connection_class)
    #@db_connection_class = 
    #  .create_connection_class("spec")
    @connection_class = double(ActiveRecord::Base)
    @adapter = double(ActiveRecord::ConnectionAdapters::AbstractAdapter)
  end


  describe "update_table_without_id" do

    it "should be able to send a correctly formed SQL statment to the ConnectionAdapter" do
      table = "preference_options_preference_types"
      data = [{"preference_type_id" => "1",
              "preference_option_id" => "2",
              "created_at" => "2011-10-11 00:54:56.137144",
              "updated_at" => "2011-10-11 00:54:56.137144",
              "fake_id" => 1},
              {"preference_type_id" => 2,
              "preference_option_id" => 2,
              "created_at" => "",
              "updated_at" => "2011-10-11 00:54:56.137144",
              "fake_id" => 1}]

      col = [ActiveRecord::ConnectionAdapters::Column.new("preference_type_id", "INTEGER"),
             ActiveRecord::ConnectionAdapters::Column.new("preference_option_id", "INTEGER"),
             ActiveRecord::ConnectionAdapters::Column.new("created_at", "datetime"),
             ActiveRecord::ConnectionAdapters::Column.new("updated_at", "datetime")]
      sql = "UPDATE preference_options_preference_types SET preference_type_id = '1', created_at = '2011-10-11 00:54:56.137144' WHERE 1=1 AND preference_type_id = '2' AND preference_option_id = '2' AND created_at IS NULL AND updated_at = '2011-10-11 00:54:56.137144' "

      @connection_class.should_receive(:connection).and_return(@adapter)
      @instance = RailsDbAdmin::TableSupport.new(@connection_class)
      @adapter.should_receive(:columns).with(table).and_return(col)
      @adapter.should_receive(:execute).with(sql)
      @instance.update_table_without_id(table, data)
    end

  end

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
