module RailsDbAdmin
  class TableSupport

    def initialize(database_connection_class)
     @connection = database_connection_class.connection
    end

    def columns(table)
      @columns ||= @connection.columns(table)
    end

    def update_table(table, id, data)
      arel_table = Arel::Table::new(table)
      clean_nulls!(table, data)
      data = RailsDbAdmin::TableSupport.arel_attr(data, arel_table)

      pk = id[0].to_sym
      query = arel_table.where(arel_table[pk].eq(id[1])).compile_update(data)

      @connection.execute(query.to_sql)
    end

    def update_table_without_id(table, data)
      #makes all values strings
      data[0].delete('fake_id')
      data[1].delete('fake_id')
      data.map! do |item|
        item.each do |k,v|
          item[k] = v.to_s
        end
        item
      end

      clean_nulls!(table, data)
      changed_values = data[0].diff(data[1])

      arel_table = Arel::Table::new(table)
      updates = RailsDbAdmin::TableSupport.arel_attr(changed_values, arel_table)
      query = arel_table

      data[1].each do |k, v|
        query = query.where(arel_table[k.to_sym].eq(v))
      end
      query = query.compile_update(updates)

      @connection.execute(query.to_sql)
    end

    def delete_row(table, id)
      arel_table = Arel::Table::new(table)
      pk = id[0].to_sym
      query = arel_table.where(arel_table[pk].eq(id[1])).compile_delete

      @connection.execute(query.to_sql)
    end

    def insert_row(table, data, no_id=false)
      clean_nulls!(table, data)
      arel_table = Arel::Table::new(table)
      data = RailsDbAdmin::TableSupport.arel_attr(data, arel_table)

      sql = arel_table.compile_insert(data)
      #TODO: Test with Oracle; ActiveRecord source indicates
      #that we may need to pass in the id to use here
      id = @connection.insert(sql.to_sql)

      if no_id
        #need to gen a random number for fake_id...
        id = Random.rand(500-100) + 100
      end
      id
    end

    def primary_key(table)
      [@connection.primary_key(table),nil]
    end

    def primary_key?(table)
      @connection.supports_primary_key? && !@connection.primary_key(table).nil?
    end

	  
	  def table_contains_column(table, column_name)
	    
	    column_names = columns(table).map{|column| column.name.to_sym}
	    
	    column_names.include?(column_name)
	  end
	
    def clean_nulls!(table, data)
      if data.class == Array
        data.each {|x| clean_nulls!(table, x)}
      end

      data.collect do |k,v|
        if v == "" || v == 0
          column = columns(table).collect do |x|
            if (x.name == k)
              break x
            end
          end
          if column.null
            data[k] = nil
          end
        end
      end
    end

    def self.database_rows_to_hash(rows)
      records = []

      rows.each do |row|
        # record = nil
        # row.each {|k, v|
        #   record = record.nil? ? {k.to_sym => v} : record.merge({k.to_sym => v})
        # }
        # records << record

        # simplifying the above with to_hash.symbolize_keys
        records << row.to_hash.symbolize_keys
      end

      records.reverse
    end

    #Construct a hash of ARel relation objects as
    #keys and assign with values for use in update
    #calls
    def self.arel_attr data, arel_table
      cln_hsh = {}
      data.each do |k,v|
        cln_hsh[arel_table[k.to_sym]] = v
      end
      cln_hsh
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
