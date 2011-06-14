class ErpApp::Desktop::RailsDbAdmin::QueriesController < ErpApp::Desktop::RailsDbAdmin::BaseController
  def save_query
    query = params[:query]
    query_name  = params[:query_name]
    
    @query_support.save_query(query, query_name, database_connection_name)
    
    render :inline => "{success:true}"
  end
  
  def saved_queries
    names = @query_support.get_saved_query_names(database_connection_name)
    
    names_hash_array = []
    
    names.each do |name| 
      names_hash_array << {:display => name, :value => name}
    end unless names.empty?
    
    render :inline => "{data:#{names_hash_array.to_json}}"
  end
  
  def delete_query
    query_name  = params[:query_name]
    
    @query_support.delete_query(query_name, database_connection_name)
   
    renderr :text => "{success:true}"
  end
  
  def saved_queries_tree
    names = @query_support.get_saved_query_names(database_connection_name)
    
    names_tree_nodes = ""
    
    names.each do |name| 
      names_tree_nodes = names_tree_nodes + "{text:\"#{name}\", id:\"#{name}\", iconCls:\"icon-document\", href:\"javascript:void(0);window.RailsDbAdmin.displayAndExecuteQuery('#{name}')\", leaf:true},"
    end unless names.empty?
    
    names_tree_nodes = names_tree_nodes[0..names_tree_nodes.length - 2] unless names_tree_nodes.blank?
    
    render :text => "[#{names_tree_nodes}]"
  end
  
  def open_query
    query_name = params[:query_name]
    
    query = @query_support.get_query(query_name, database_connection_name)
    
    render :inline => "{success:true, query:\"#{query}\"}"
  end  
  
  def open_and_execute_query
    query_name = params[:query_name]
    
    query = @query_support.get_query(query_name, database_connection_name)
    
    columns, values, exception = @query_support.execute_sql(query)

    if columns.empty? || values.empty?
      json_text = "{success:false,query:\"#{query}\",exception:\"Empty result set\"}"
    elsif exception.nil?

      columns_array = '['
      columns.each do |column|
        columns_array += RailsDbAdmin::Extjs::JsonColumnBuilder.build_readonly_column(column) + ","
      end
      columns_array = columns_array[0..columns_array.length - 2]
      columns_array = columns_array + "]"

      fields_array = '['
      columns.each do |column|
        fields_array += "{name:\"#{column}\"},"
      end
      fields_array = fields_array[0..fields_array.length - 2]
      fields_array = fields_array + "]"

      data_array = values.to_json

      json_text = "{success:true,"
      json_text += "query:\"" + query
      json_text += "\",columns:" + columns_array
      json_text += ",fields:"+ fields_array
      json_text += ",data:" + data_array
      json_text += "}"

    else
      exception.gsub!("\n"," ")
      exception.gsub!('"','\\"')
      json_text = "{success:false,query:\"#{query}\",exception:\"#{exception}\"}"
    end


    render :text => json_text
  end
  
  def select_top_fifty
    table = params[:table]
    
    sql, json_data = @query_support.select_top_fifty(table)
    
    json_text = "{success:true,"
    json_text += "sql:\"#{sql}\","
    json_text += "data:#{json_data},"
    json_text += "columns:#{build_grid_columns(table)},"
    json_text += "fields:#{build_store_fields(table)}"
    json_text += "}"
    
    render :text => json_text
  end
  
  def execute_query
    sql = params[:sql]
    
    columns, values, exception = @query_support.execute_sql(sql)
      
    if !exception.nil?
      
      exception.gsub!("\n"," ")
      exception.gsub!('"','\\"')
      json_text = "{success:false,exception:\"#{exception}\"}"
      
    elsif columns.empty? || values.empty?
      
      json_text = "{success:false,exception:\"Empty result set\"}"
      
    else exception.nil?

      columns_array = '['
      columns.each do |column|
        columns_array += RailsDbAdmin::Extjs::JsonColumnBuilder.build_readonly_column(column) + ","
      end
      columns_array = columns_array[0..columns_array.length - 2]
      columns_array = columns_array + "]"

      fields_array = '['
      columns.each do |column|
        fields_array += "{name:\"#{column}\"},"
      end
      fields_array = fields_array[0..fields_array.length - 2]
      fields_array = fields_array + "]"

      data_array = values.to_json

      json_text = "{success:true,"
      json_text += "columns:" + columns_array
      json_text += ",fields:"+ fields_array
      json_text += ",data:" + data_array
      json_text += "}"
    end

    renderr :text => json_text
  end
end