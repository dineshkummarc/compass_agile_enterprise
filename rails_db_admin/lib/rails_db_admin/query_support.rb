module RailsDbAdmin
	class QuerySupport
	  QUERY_LOCATION = "#{Rails.root}/public/rails_db_admin/queries/"
	  
	  def initialize(database_connection_class)
	   @connection = database_connection_class.connection
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
	    query = @connection.add_limit_offset!("SELECT * FROM #{table}", {:limit => 50})
	    
	    rows = @connection.select_all(query)
	    records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)
	    
	    return query, records
	  end
	  
	  def get_saved_query_names(database_connection_name)
	    path = "#{QUERY_LOCATION}#{database_connection_name}/"
	    
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
	    path = "#{QUERY_LOCATION}#{database_connection_name}/"
	    
	    unless File.directory? path
	      FileUtils.mkdir_p(path)
	    end
	    
	    unless File.exist?("#{path}#{name}.sql")
	      File.new("#{path}#{name}.sql", 'w')
	    end
	    
	    File.open("#{path}#{name}.sql", 'w+'){|f| f.write(query) }
	  end
	  
	  def delete_query(name, database_connection_name)
	    path = "#{QUERY_LOCATION}#{database_connection_name}/"
	    
	    if File.exist?("#{path}#{name}.sql")
	      FileUtils.rm("#{path}#{name}.sql")
	    end
	  end
	  
	  def get_query(name, database_connection_name)
	    path = "#{QUERY_LOCATION}#{database_connection_name}/"
	    
	    query = ""
	    
	    if File.exist?("#{path}#{name}.sql")
	      query = File.open("#{path}#{name}.sql") { |f| f.read }
	    end
	    
	    query.gsub!("\r", " ")
	    query.gsub!("\n", " ")
	    
	    query
	  end
	end
end