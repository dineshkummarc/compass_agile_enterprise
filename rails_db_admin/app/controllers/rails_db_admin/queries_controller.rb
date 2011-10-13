module RailsDbAdmin
	class QueriesController < RailsDbAdmin::BaseController
	  def save_query
      query = params[:query]
      query_name  = params[:query_name]
		
      @query_support.save_query(query, query_name, database_connection_name)
		
      render :json => {:success => true}
	  end
	  
	  def saved_queries
      names = @query_support.get_saved_query_names(database_connection_name)
		
      names_hash_array = []
		
      names_hash_array = names.collect do |name| 
        {:display => name, :value => name}
      end unless names.empty?
		
      render :json => {:data => names_hash_array}
	  end
	  
	  def delete_query
      query_name  = params[:query_name]
      @query_support.delete_query(query_name, database_connection_name)
	   
      render :json => {:success => true}
	  end
	  
	  def saved_queries_tree
      names = @query_support.get_saved_query_names(database_connection_name)
		
      queries = []
		
      queries = names.collect do |name|
        {:text => name, :id => name, :iconCls => 'icon-document', :leaf => true}
      end unless names.empty?
		
      render :json => queries
	  end
	  
	  def open_query
      query_name = params[:query_name]
      query = @query_support.get_query(query_name, database_connection_name)
		
      render :json => {:success => true, :query => query}
	  end  
	  
	  def open_and_execute_query
      result = {}
      query_name = params[:query_name]
		
      query = @query_support.get_query(query_name, database_connection_name)
      columns, values, exception = @query_support.execute_sql(query)

      if columns.blank? || values.blank?
        result = {:success => false, :query => query, :exception => "Empty result set"}
      elsif exception.nil?
			
	      columns_array = columns.collect do |column|
          RailsDbAdmin::Extjs::JsonColumnBuilder.build_readonly_column(column)
        end
		  
        fields_array = columns.collect do |column|
          {:name => column}
        end
		  
        result = {:success => true, :query => query, :columns => columns_array, :fields => fields_array, :data => values}
      else
        exception.gsub!("\n"," ").gsub!('"','\\"')
        result = {:success => false, :query => query, :exception => exception}
      end

      render :json => result
	  end
	  
	  def select_top_fifty
      table = params[:table]
      sql, results = @query_support.select_top_fifty(table)
		
      render :json => {:success => true, :sql => sql, :columns => build_grid_columns(table), :fields => build_store_fields(table), :data => results}
	  end
	  
	  def execute_query
      sql = params[:sql]
      selection = params[:selected_sql]
      sql = sql.rstrip
      cursor_pos = params[:cursor_pos].to_i

      sql_arr = sql.split("\n")
      sql_stmt_arry = []
      sql_str = ""

      #search for the query to run based on cursor position if there
      #was nothing selected by the user
      if (selection == "")
        last_stmt_end = 0
        sql_arr.each_with_index do |val,idx|
          if val.match(';')
            sql_stmt_arry << {:begin => (idx > 0) ? last_stmt_end + 1 : 0, :end => idx}
            last_stmt_end = idx
          end
        end

        sql_stmt_arry.each do |val|
            puts val
        end

        last_sql_stmt = sql_stmt_arry.length-1
        #run the first complete query if we're in whitespace
        #at the beginning of the text area
        if cursor_pos <= sql_stmt_arry[0].fetch(:begin)
          sql_str = sql_arr.values_at(sql_stmt_arry[0].fetch(:begin),
                                      sql_stmt_arry[0].fetch(:end)).join(" ")
        #run the last query if we're in whitespace at the end of the
        #textarea
        elsif cursor_pos > sql_stmt_arry[last_sql_stmt].fetch(:begin)
          sql_str = sql_arr.values_at(sql_stmt_arry[last_sql_stmt].fetch(:begin),
                                      sql_stmt_arry[last_sql_stmt].fetch(:end)).join(" ")
        #run query based on cursor position
        else
          sql_stmt_arry.each do |sql_stmt|
            if cursor_pos >= sql_stmt.fetch(:begin) &&
              cursor_pos <= sql_stmt.fetch(:end)
              sql_str = sql_arr.values_at(sql_stmt.fetch(:begin),
                                          sql_stmt.fetch(:end)).join(" ")
            end
          end
        end
      else
        sql_str = selection
      end

      columns, values, exception = @query_support.execute_sql(sql_str)

      if !exception.nil?
        exception = exception.gsub("\n"," ")
        result = {:success => false, :exception => exception}
      elsif columns.empty? || values.empty?
        result = {:success => false, :exception => "Empty result set"}
      else exception.nil?
        columns_array = columns.collect do |column|
          RailsDbAdmin::Extjs::JsonColumnBuilder.build_readonly_column(column)
        end
		  
        fields_array = columns.collect do |column|
          {:name => column}
        end

        result = {:success => true, :sql => sql, :columns => columns_array, :fields => fields_array, :data => values}
      end

      render :json => result
	  end
	end
end
