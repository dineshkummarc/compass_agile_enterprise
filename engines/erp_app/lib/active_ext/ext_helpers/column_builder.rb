module ActiveExt::ExtHelpers::ColumnBuilder

  def self.build_column(column)
    column_hash = nil
    
    #if this is an association sql_type will be blank, use string column
    if column.sql_type.blank? || column.sql_type == NilClass
      column_hash = self.send("build_string_column", column.name, column.options)
    else
      column_hash = self.send("build_#{column.sql_type.to_s}_column", column.name, column.options)
    end

    column_hash
  end

  private

  def self.build_boolean_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'date',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
      :renderer => 'function(v) {
        result = "False";
        
        if(v == 1){
          result = "True";
        }
        return result;
      }'
    }

    column[:editor] = {:xtype => "booleancolumneditor", :disabled => options[:readonly].blank? ? false : options[:readonly]}

    column
  end
  
  def self.build_date_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'date',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 200 : options[:width],
      :renderer => "Ext.util.Format.dateRenderer('m/d/Y')"
    }

    column[:editor] = {:xtype => "datefield", :disabled => options[:readonly].blank? ? false : options[:readonly]}

    column
  end
  
  def self.build_datetime_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'date',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 200 : options[:width],
      :renderer => "Ext.util.Format.dateRenderer('m/d/Y')"
    }

    column[:editor] = {:xtype => "datefield", :disabled => options[:readonly].blank? ? false : options[:readonly]}

    column
  end

  def self.build_string_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'string',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
    }

    column[:editor] = {:xtype => "textfield", :disabled => options[:readonly].blank? ? false : options[:readonly]}
    
    column
  end

  def self.build_integer_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'number',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
    }

    column[:editor] = {:xtype => "numberfield", :disabled => options[:readonly].blank? ? false : options[:readonly]}
    
    column
  end

  def self.build_decimal_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'float',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
    }

    column[:editor] = {:xtype => "numberfield", :disabled => options[:readonly].blank? ? false : options[:readonly]}
    
    column
  end

  def self.build_float_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'float',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
    }

    column[:editor] = {:xtype => "numberfield", :disabled => options[:readonly].blank? ? false : options[:readonly]}
    
    column
  end

end
