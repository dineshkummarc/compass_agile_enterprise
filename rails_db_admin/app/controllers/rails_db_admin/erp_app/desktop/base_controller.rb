module RailsDbAdmin
  module ErpApp
    module Desktop
      class BaseController < ::ErpApp::Desktop::BaseController
        before_filter :setup_database_connection
	  
        def databases
          result = {:databases => []}
          Rails.configuration.database_configuration.each do |k, v|
            result[:databases] << {:display => k, :value => k}
          end
		
          render :json => result
        end
	  
        def tables
          result_hash = []

          if params[:node] == "root"
            tables = []
            table_names = @database_connection_class.connection.tables
            table_names.each do |table|
              tables << {:name => table, :display => table} unless table.blank?
            end

            tables.sort! { |a,b| a[:name].downcase <=> b[:name].downcase }

            tables.each do |table|
              result_hash << {:isTable => true,
                :text => table[:display],
                :id => table[:display],
                :iconCls => 'icon-data',
                :leaf => false}
            end
          else
            columns = @database_connection_class.connection.columns(params[:node])
            columns.each do |column|
              result_hash << {:text => "#{column.name} : #{column.type}", :iconCls => 'icon-gear', :leaf => true}
            end
          end

          render :json => result_hash
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

          if @table_support.primary_key?(table)
            id = @table_support.primary_key(table)
            id[1] = @table_support.insert_row(table, params[:data])
            record = @json_data_builder.get_row_data(table, id)
          else
            params[:data].delete('fake_id')
            fake_id = @table_support.insert_row(table, params[:data],true)
            record = @json_data_builder.get_row_data_no_id(table, params[:data])
            record[:fake_id] = fake_id
          end

          {:success => true, :data => record}
        end

        def update_table_data
          table = params[:table]

          if @table_support.primary_key?(table)
            id = @table_support.primary_key(table)
            id[1] = params[:data][0][id[0]]
            params[:data][0].delete(id[0])

            @table_support.update_table(table, id, params[:data][0])
            record = @json_data_builder.get_row_data(table, id)
          else
            fake_id = params[:data][0]['fake_id']
            @table_support.update_table_without_id(table, params[:data])
            record = @json_data_builder.get_row_data_no_id(table, params[:data][0])
            record['fake_id'] = fake_id
          end

          {:success => true, :data => record}
        end

        def delete_table_row
          table = params[:table]
          id = params[:id]
          exception = nil

          if @table_support.primary_key?(table)
            pk = @table_support.primary_key(table)
            pk[1] = id
            @table_support.delete_row(table.pluralize.underscore,pk)
          else
            exception = "Unable to determine primary key on this table. "\
              "Delete not performed"
          end

          if (exception == nil)
            {:success => true, :data => []}
          else
            {:success => false, :data => [], :exception => exception}
          end
        end

        def setup_database_connection
          @database_connection_class = RailsDbAdmin::ConnectionHandler.create_connection_class(database_connection_name)

          @query_support = RailsDbAdmin::QuerySupport.new(@database_connection_class, database_connection_name)
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
  end
end
