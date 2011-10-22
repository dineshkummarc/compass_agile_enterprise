module RailsDbAdmin
	class BaseController < ErpApp::Desktop::BaseController
	  before_filter :setup_database_connection
	  
	  def databases
		result = {:databases => []}
		Rails.configuration.database_configuration.each do |k, v|
		  result[:databases] << {:display => k, :value => k}
		end
		
		render :json => result
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

		render :json => tables_hash
	  end

    def setup_table_grid
      result = {:success => true}
      table = params[:table]
      columns = @database_connection_class.connection.columns(table)


      if @table_support.table_contains_column(table, :id)
        result[:columns] =
          RailsDbAdmin::Extjs::JsonColumnBuilder.build_grid_columns(columns)
        result[:model] = table
        result[:fields] =
          RailsDbAdmin::Extjs::JsonColumnBuilder.build_store_fields(columns)
        result[:validations] = []
        result[:id_property] = "id"
      else
        result[:columns] =
          RailsDbAdmin::Extjs::JsonColumnBuilder.build_grid_columns(columns, true)
        result[:model] = table
        result[:fields] =
          RailsDbAdmin::Extjs::JsonColumnBuilder.build_store_fields(columns, true)
        result[:validations] = []
        result[:id_property] = "fake_id"
      end

      render :json => result
    end

    def table_data
      render :json => if request.get?
        get_table_data
      elsif request.post?
        create_table_row
      elsif request.put?
        update_table_data
      elsif request.delete?
        delete_table_row
      end
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
      record = nil

      if params[:data].has_key?("fake_id")
        params[:data].delete('fake_id')
        fake_id = @table_support.insert_row(table, params[:data],true)
        record = @json_data_builder.get_row_data_no_id(table, params[:data])
        record[:fake_id] = fake_id
      else
        inserted_id = @table_support.insert_row(table, params[:data])
        record = @json_data_builder.get_row_data(table, inserted_id)
      end

      {:success => true, :data => record}
    end

    def update_table_data
      table = params[:table]
      id = params[:data][0]['id']

      if id != nil
        params[:data][0].delete('id')

        @table_support.update_table(table, id, params[:data][0])
        record = @json_data_builder.get_row_data(table, id)
      else
        @table_support.update_table_without_id(table, params[:data])
        record = @json_data_builder.get_row_data_no_id(table, params[:data][0])
      end

      {:success => true, :data => record}
    end

    def delete_table_row
      table = params[:table]
      id = params[:id]
      exception = nil

      begin
        @table_support.delete_row(table.pluralize.underscore, id)
      rescue ActiveRecord::StatementInvalid => exception
        exception = "Delete operation not supported on tables without an ID column"
        #@table_support.delete_fake_id_row(table, params[:data])
      end


      if (exception == nil)
        {:success => true, :data => []}
      else
        {:success => false, :data => [], :exception => exception}
      end
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
		database_name = Rails.env

		unless params[:database].blank?
		  database_name = params[:database]
		end
		
		database_name
	  end
  end
end
