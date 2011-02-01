module ActiveExt::ExtHelpers::ColumnBuilder

  def self.build_column(column, options={})
    column_hash = nil
    
    #if this is an association sql_type will be blank, use string column
    if column.sql_type.blank? || column.sql_type == NilClass
      column_hash = self.send("build_string_column", column.name, options)
    else
      column_hash = self.send("build_#{column.sql_type.to_s}_column", column.name, options)
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

    if options[:readonly].blank? || !options[:readonly]
      column[:editor] = {:xtype => "booleancolumneditor"}
    end

    column
  end
  
  def self.build_date_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'date',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
      :renderer => 'function(v) {return v.format("Y-M-D");}'
    }

    if options[:readonly].blank? || !options[:readonly]
      column[:editor] = {:xtype => "datefield"}
    end

    column
  end
  
  def self.build_datetime_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'date',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
      :renderer => 'function(v) {return v.format("Y-m-d h:i:s");}'
    }

    if options[:readonly].blank? || !options[:readonly]
      column[:editor] = {:xtype => "datefield"}
    end

    column
  end

  def self.build_string_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'string',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
    }

    if options[:readonly].blank? || !options[:readonly]
      column[:editor] = {:xtype => "textfield"}
    end
    
    column
  end

  def self.build_integer_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'number',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
    }

    if options[:readonly].blank? || !options[:readonly]
      column[:editor] = {:xtype => "numberfield"}
    end
    
    column
  end

  def self.build_decimal_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'float',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
    }

    if options[:readonly].blank? || !options[:readonly]
      column[:editor] = {:xtype => "numberfield"}
    end
    
    column
  end

  def self.build_float_column(column_name, options={})
    column = {
      :header => column_name,
      :type => 'float',
      :dataIndex => column_name,
      :width => options[:width].nil? ? 150 : options[:width],
    }

    if options[:readonly].blank? || !options[:readonly]
      column[:editor] = {:xtype => "numberfield"}
    end
    
    column
  end

end
