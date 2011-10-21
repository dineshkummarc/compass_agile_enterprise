module RailsDbAdmin
  module  Extjs
    class JsonDataBuilder

      def initialize(database_connection_class)
        @connection = database_connection_class.connection
      end

      def build_json_data(options)
        unless options[:table]
          raise '!Error Must specify table'
        end

        total_count = self.get_total_count(options[:table])

        if options[:limit] && options[:offset] && options[:order]
          query = @connection.add_limit_offset!("SELECT * FROM #{options[:table]} order by #{options[:order]}", {:limit => options[:limit], :offset => options[:offset], :order => options[:order]})
        elsif options[:limit] && options[:order]
          query = @connection.add_limit_offset!("SELECT * FROM #{options[:table]} order by #{options[:order]}", {:limit => options[:limit], :order => options[:order]})
        elsif options[:limit] && !options[:order]
          query = @connection.add_limit_offset!("SELECT * FROM #{options[:table]}", {:limit => options[:limit]})
        elsif !options[:limit] && options[:order]
          query = "SELECT * FROM #{options[:table]} order by #{options[:order]}"
        else
          query = "SELECT * FROM #{options[:table]}"
        end


        rows = @connection.select_all(query)
        records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)
        if !records.empty? && !records[0].has_key?("id")
          records = RailsDbAdmin::TableSupport.add_fake_id_col(records)
        end

        {:totalCount => total_count, :data => records}
      end

      def get_row_data(table, id)
        query = "select * from #{table} where id = #{id}"

        rows = @connection.select_all(query)
        records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)
        records[0]
      end

      #This will retrieve data from tables without an
      #'id' field.  Will also add a 'fake_id' so that it can
      #be used by editable ExtJS grids.
      def get_row_data_no_id(table, row_hash)
        columns = @connection.columns(table)

        where_sql = RailsDbAdmin::TableSupport.build_where_clause(row_hash, columns)
        query = "SELECT * FROM #{table}" << where_sql
        rows = @connection.select_all(query)
        records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)
        records = RailsDbAdmin::TableSupport.add_fake_id_col(records)
        records[0]
      end

      def get_total_count(table)
        total_count = 0
        rows = @connection.select_all("SELECT COUNT(*) as count FROM #{table}")
        records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)
        total_count = records[0][:count]
			
        total_count
      end
	end
  end
end
