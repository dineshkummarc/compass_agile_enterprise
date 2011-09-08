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
		
      columns, values, exception = @query_support.execute_sql(sql)
		  
      if !exception.nil?
        exception.gsub!("\n"," ").gsub!('"','\\"')
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