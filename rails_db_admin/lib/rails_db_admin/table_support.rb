module RailsDbAdmin
	class TableSupport

	  def initialize(database_connection_class)
	   @connection = database_connection_class.connection
	  end
	
	  def update_table(table, id, data)
	    columns = @connection.columns(table)
	
	    sql = "update #{table} set "
	
      #TODO: Should make sure all values are strings, otherwise gsub could fail here
	    data.each do |k,v|
	      columns.each do |column|
	        if column.name == k
	          sql << if column.type == :string or column.type == :text
	            " #{k} = '#{v.gsub("'","''")}',"
	          else
	            (v.blank? ? " #{k} = null," : " #{k} = '#{v.gsub("'","''")}',")
	          end
	        end
	      end
	    end
	
	    sql = sql[0..sql.length - 2]
	
	    sql << " where id = #{id}"
	    
	    @connection.execute(sql)
	  end

    def update_table_without_id(table, data)
      columns = @connection.columns(table)
      sql = "UPDATE #{table} SET"


      #makes all values strings
      data.map! do |item|
        item.each do |k,v|
          item[k] = v.to_s
        end
        item
      end

      changed_values = data[0].diff(data[1])

      changed_values.each do |k,v|
        columns.each do |column|
          if column.name == k
            sql << if column.type == :string or column.type == :text
              " #{k} = '#{v.gsub("'","''")}',"
            else
              (v.blank? ? " #{k} = null," : " #{k} = '#{v.gsub("'","''")}',")
            end
          end
        end
      end

      sql = sql[0..sql.length - 2]


      sql << RailsDbAdmin::TableSupport.build_where_clause(data[1], columns)

      @connection.execute(sql)
    end

    def self.build_where_clause(row_hash, columns)

      where_sql = " WHERE 1=1 "

      #now build the WHERE clause
      row_hash.each do |k,v|
        columns.each do |column|
          if column.name == k
            where_sql << "AND"
            where_sql << if column.type == :string or column.type == :text
              " #{k} = '#{v.gsub("'","''")}' "
            else
              (v.blank? ? " #{k} IS NULL " : " #{k} = '#{v.gsub("'","''")}' ")
            end
          end
        end
      end

      where_sql
    end
	
	  def delete_row(table, id)
	    sql = "delete from #{table} where id = #{id}"
	
	    @connection.execute(sql)
	  end
	
	  def insert_row(table, data)
	    columns = @connection.columns(table)
	
	    sql = "insert into #{table} ("
	
	    columns.delete_at(0)
	
	    column_names = columns.map{|column| column.name}
	    column_names = column_names.join(", ")
	
	    sql << column_names
	    sql << ") values ( "
	
	    columns.each do |column|
	      found = false
	      data.each do |k,v|
	        if column.name == k
	          found = true
	          sql << v.blank? ? "null," : "'#{v}',"
	        end
	      end
	      sql << "null,"  unless found
	    end
	
	    sql = sql[0..sql.length - 2]
	
	    sql << ")"
	
	    @connection.execute(sql)
	    
	    query = "select MAX(id) as max_id from #{table}"
	
	    rows = @connection.select_all(query)
	    records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)
	    records[0][:max_id]
	
	  end
	  
	  def table_contains_column(table, column_name)
	    columns = @connection.columns(table)
	    
	    column_names = columns.map{|column| column.name.to_sym}
	    
	    column_names.include?(column_name)
	  end
	
	  def self.database_rows_to_hash(rows)
	    records = []
	    
	    rows.each do |row|
	      record = nil
	      row.each {|k, v|
	        record = record.nil? ? {k.to_sym => v} : record.merge({k.to_sym => v})
	      }
	      records << record
	    end
	
	    records.reverse
	  end

    #Accepts an array of table row hashes and adds a 'fake_id'
    #field to each one with a generated number.  Useful
    #for prepraring many-to-many data to be edited in ExtJS
    #grids
    def self.add_fake_id_col(rows_hash)

      nums = (1..(rows_hash.length)).to_a
      result = rows_hash.map do |item|
        item[:fake_id] = nums.shift
        item
      end
      return result
    end
  end
end
