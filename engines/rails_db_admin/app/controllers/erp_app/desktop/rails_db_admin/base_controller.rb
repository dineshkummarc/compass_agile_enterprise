class ErpApp::Desktop::RailsDbAdmin::BaseController < ErpApp::Desktop::BaseController
  before_filter :setup_database_connection

  def login_path
    return rails_db_admin_login_path
  end

  def index

  end
  
  def databases
    json_text = '{"databases":['
    
    config = Rails::Configuration.new

    config.database_configuration.each do |k, v|
      json_text += "{display:\"#{k}\", value:\"#{k}\"},"
    end
    
    json_text = json_text[0..json_text.length - 2]
    json_text += ']}'
    
    render :inline => json_text
  end
  
  def tables
    tables_hash = []
    tables = []
    table_names = @database_connection_class.connection.tables
    table_names.each do |table|
      tables << {:name => table, :display => table} unless table.blank?
    end

    tables.sort! { |a,b| a[:name].downcase <=> b[:name].downcase }

    tables.each do |table|
      tables_hash << build_table_tree(table)
    end

    render :inline => tables_hash.to_json
  end

  def setup_table_grid
    table = params[:table]

    if @table_support.table_contains_column(table, :id) 
      json_text = "{success:true,"
      json_text += "columns:" + build_grid_columns(table)
      json_text += ",model:'"+table+"'"
      json_text += ",fields:"+ build_store_fields(table)
      json_text += ",validations:[]"
      json_text += "}"
    else
      json_text = "{success:false}"
    end
    
    render :inline => json_text
  end

  def table_data
    json_text = nil

    if request.get?
      json_text = get_table_data
    elsif request.post?
      json_text = create_table_row
    elsif request.put?
      json_text = update_table_data
    elsif request.delete?
      json_text = delete_table_row
    end

    render :inline => json_text
  end

  private

  def get_table_data
    start = params[:start] || 0
    limit = params[:limit] || 30
    table = params[:table]

    order = nil
    
    if @table_support.table_contains_column(table, :id)
      order = 'id desc'
    elsif @table_support.table_contains_column(table, :created_at)
      order = 'created_at desc'
    end
    
    @json_data_builder.build_json_data(:table => table, :limit => limit, :offset => start, :order => order)
  end

  def create_table_row
    table = params[:table]
    params[:data].delete('id')

    inserted_id = @table_support.insert_row(table, params[:data])

    record = @json_data_builder.get_row_data(table, inserted_id)

    json_text = "{\"success\":true,data:#{record.to_json}}"

    json_text
  end

  def update_table_data
    table = params[:table]
    id = params[:data]['id']
    params[:data].delete('id')

    @table_support.update_table(table, id, params[:data])
    record = @json_data_builder.get_row_data(table, id)

    json_text = "{\"success\":true,data:"

    json_text += record.to_json

    json_text += '}'

    json_text
  end

  def delete_table_row
    table = params[:table]
    id = params[:id]

    table = table.pluralize.underscore
    
    @table_support.delete_row(table, id)

    json_text = "{\"success\":true,data:[]}"

    json_text
  end

  def build_grid_columns(table)
    columns = @database_connection_class.connection.columns(table)
    
    array_text = "["

    columns.each do |column|
      array_text += RailsDbAdmin::Extjs::JsonColumnBuilder.build_column_from_column_obj(column) + ","
    end

    array_text = array_text[0..array_text.length - 2]

    array_text += "]"

    array_text
  end

  def build_store_fields(table)
    columns = @database_connection_class.connection.columns(table)

    array_text = "["

    columns.each do |column|
      array_text += "{name:\"#{column.name}\"},"
    end

    array_text = array_text[0..array_text.length - 2]

    array_text += "]"

    array_text
  end

  def build_table_tree(table)
    columns = @database_connection_class.connection.columns(table[:name])

    table_hash = {:isTable => true, :text => table[:display], :id => table[:display], :iconCls => 'icon-data', :leaf => false, :children => []}

    columns.each do |column|
      table_hash[:children] << {:text => "#{column.name} : #{column.type}", :iconCls => 'icon-gear', :leaf => true}
    end

    table_hash
  end

  def setup_database_connection
    @database_connection_class = RailsDbAdmin::ConnectionHandler.create_connection_class(database_connection_name)

    @query_support = RailsDbAdmin::QuerySupport.new(@database_connection_class)
    @table_support = RailsDbAdmin::TableSupport.new(@database_connection_class)
    @json_data_builder = RailsDbAdmin::Extjs::JsonDataBuilder.new(@database_connection_class)
  end
  
  def database_connection_name
    database_name = RAILS_ENV

    unless params[:database].blank?
      database_name = params[:database]
    end
    
    database_name
  end
end
