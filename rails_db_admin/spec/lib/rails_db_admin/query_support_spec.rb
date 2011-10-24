require "spec_helper"

describe RailsDbAdmin::QuerySupport do
  before(:each) do
    @connection_class = double(ActiveRecord::Base)
    @adapter = double(ActiveRecord::ConnectionAdapters::AbstractAdapter)
    @connection_class.should_receive(:connection).and_return(@adapter)
    @instance = RailsDbAdmin::QuerySupport.new(@connection_class)

  end

  describe "select_top_fifty" do

    it "should pass well formed sql to select_all" do

      @sql = "SELECT  * FROM \"test_table\"  LIMIT 50"

      @adapter.should_receive(:select_all).with(@sql).and_return([])

      @instance.select_top_fifty("test_table")

    end

    it "should return a sql statement and an array of hashes" do

      @sql = "SELECT  * FROM \"test_table\"  LIMIT 50"

      @return_arry = [{:col_a => "some_val"},
                      {:col_a => "some_val2"}]

      @adapter.should_receive(:select_all).with(@sql).and_return([])

      RailsDbAdmin::TableSupport.stub(:database_rows_to_hash).
        and_return(@return_arry)

      sql, records = @instance.select_top_fifty("test_table")
      sql.should eq(@sql)
      records.should eq(@return_arry)

    end


  end

end
