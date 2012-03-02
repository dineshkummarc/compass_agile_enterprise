module RailsDbAdmin
  module Extjs
    class JsonColumnBuilder
      def self.build_column_from_column_obj(column)
        self.send("build_#{column.type.to_s}_column", column.name)
      end

      #construct an array of column objects based on a
      #AR connection.columns object
      def self.build_grid_columns(columns, add_fake_id = false)
        grid_columns = columns.collect do |column|
          RailsDbAdmin::Extjs::JsonColumnBuilder.build_column_from_column_obj(column)
        end
        if add_fake_id
          grid_columns << {:header => "fake_id",
                             :type => "number",
                             :dataIndex => "fake_id",
                             :hidden => true}
        end
        grid_columns
      end

      def self.build_store_fields(columns, add_fake_id = false)
        grid_fields = columns.collect do |column|
          {:name => column.name}
        end

        if add_fake_id
          grid_fields << {:name => "fake_id"}
        end

        grid_fields
      end

      def self.build_readonly_column(column_name)
        {
          :header => column_name,
          :type => 'string',
          :dataIndex  => column_name,
          :width => 150
        }
      end


      private

      def self.build_boolean_column(column_name)
        {
          :header => column_name,
          :type => 'boolean',
          :dataIndex  => column_name,
          :width => 150,
          :editor => {:xtype => 'booleancolumneditor'},
          :renderer => NonEscapeJsonString.new("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.renderBooleanColumn")
        }
      end

      def self.build_date_column(column_name)
        hash = {
          :header => column_name,
          :type => 'date',
          :dataIndex  => column_name,
          :width => 150,
        }
        hash[:editor] = {:xtype => 'textfield'} if (column_name != "created_at" && column_name != "updated_at")

        hash
      end

      def self.build_datetime_column(column_name)
        hash = {
          :header => column_name,
          :type => 'date',
          :dataIndex  => column_name,
          :width => 150,
        }
        hash[:editor] = {:xtype => 'textfield'} if (column_name != "created_at" && column_name != "updated_at")

        hash
      end

      def self.build_string_column(column_name)
        {
          :header => column_name,
          :type => 'string',
          :dataIndex  => column_name,
          :width => 150,
          :editor => {:xtype => 'textfield'}
        }
      end

      def self.build_text_column(column_name)
        {
          :header => column_name,
          :type => 'string',
          :dataIndex  => column_name,
          :width => 150,
          :editor => {:xtype => 'textarea'}
        }
      end

      def self.build_integer_column(column_name)
        hash = {
          :header => column_name,
          :type => 'number',
          :dataIndex  => column_name,
          :width => 150,
        }
        hash[:editor] = {:xtype => 'textfield'} if column_name != "id"

        hash
      end

      def self.build_decimal_column(column_name)
        hash = {
          :header => column_name,
          :type => 'float',
          :dataIndex  => column_name,
          :width => 150,
        }
        hash[:editor] = {:xtype => 'textfield'} if column_name != "id"

        hash
      end

      def self.build_float_column(column_name)
        hash = {
          :header => column_name,
          :type => 'float',
          :dataIndex  => column_name,
          :width => 150,
        }
        hash[:editor] = {:xtype => 'textfield'} if column_name != "id"

        hash
      end
    end
  end
end
