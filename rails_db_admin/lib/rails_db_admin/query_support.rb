module RailsDbAdmin
	class QuerySupport
    def initialize(database_connection_class)
     @connection = database_connection_class.connection
     @query_location = RailsDbAdmin::QUERY_LOCATION
    end
	
	  def execute_sql(sql)
	    begin
	      rows = @connection.select_all(sql)
	    rescue => ex
	      return nil, nil, ex.message
	    end
	
	    values = []
	    columns = []
	
	    unless rows.nil? || rows.empty?
	      columns = rows[0].keys
	      rows.each do |row|
	        values << row
	      end
	    end
	    
	    return columns, values, nil
	  end

    def select_top_fifty(table)
      #Actually, sanitizing here is pretty redundent since it's a constant...
      query = "SELECT * FROM #{table} LIMIT #{@connection.sanitize_limit(50)}"

      rows = @connection.select_all(query)
      records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)

      return query, records
    end

	  def get_saved_query_names(database_connection_name)
	    path = "#{@query_location}#{database_connection_name}/"
	    
	    query_files = []
	    
	    if File.directory? path
	      query_files = Dir.entries(path).map{|directory| directory}
	      query_files.delete_if{|name| name =~ /^\./}
	      query_files.each do |file_name|
	        file_name.gsub!('.sql', '')
	      end
	    end
	    
	    query_files
	  end
	  
	  def save_query(query, name, database_connection_name)
	    path = "#{@query_location}#{database_connection_name}/"
	    
	    FileUtils.mkdir_p(path) unless File.directory? path
	    File.new("#{path}#{name}.sql", 'w') unless File.exist?("#{path}#{name}.sql")
	    File.open("#{path}#{name}.sql", 'w+'){|f| f.write(query) }
	  end
	  
	  def delete_query(name, database_connection_name)
	    path = "#{@query_location}#{database_connection_name}/"
	    FileUtils.rm("#{path}#{name}.sql") if File.exist?("#{path}#{name}.sql")
	  end
	  
    def get_query(name, database_connection_name)
      path = "#{@query_location}#{database_connection_name}/"

      query = ""
      query = File.open("#{path}#{name}.sql") { |f| f.read } if File.exist?("#{path}#{name}.sql")

      return query
    end
  end
end
