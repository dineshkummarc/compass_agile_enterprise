module ExtScaffold::TableBuilder
      
  def self.generate_columns_and_fields(model, options={})
    columns = self.build_columns(model, options)
    fields  = self.build_fields(model, options)

    return columns, fields
  end

  private

  def self.build_columns(model, options)
    array_text = "["

    #add id column if showing it
    if options[:show_id]
      array_text << ExtScaffold::ColumnBuilder.build_column_from_column_obj(model.columns.select{|c| c.name == 'id'}[0], {:readonly => true}) + ","
    end

    #build columns for each attribute
    unless options[:only].blank?
      options[:only].each do |column|
        if column.is_a?(Hash)
          col_name = column.keys.first
          col_options = column.values.first
          array_text << ExtScaffold::ColumnBuilder.build_column_from_column_obj(model.columns.select{|c| c.name == col_name.to_s}[0], col_options) + ","
        else
          array_text << ExtScaffold::ColumnBuilder.build_column_from_column_obj(model.columns.select{|c| c.name == column.to_s}[0]) + ","
        end
      end
    else
      model.columns.each do |column|
        array_text << ExtScaffold::ColumnBuilder.build_column_from_column_obj(column) + ","
      end
    end

    #add timestamp columns if showing them
    if options[:show_timestamps]
      array_text << ExtScaffold::ColumnBuilder.build_column_from_column_obj(model.columns.select{|c| c.name == 'created_at'}[0], {:readonly => true}) + ","
      array_text << ExtScaffold::ColumnBuilder.build_column_from_column_obj(model.columns.select{|c| c.name == 'updated_at'}[0], {:readonly => true}) + ","
    end
    
    array_text = array_text[0..array_text.length - 2]
    
    array_text << "]"
  end

  def self.build_fields(model, options)
    array_text = "["

    #always add id, only attribute that is always required
    array_text << "{\"name\":\"id\",\"allowBlank\":false},"

    unless options[:only].blank?
      options[:only].each do |column|
        if column.is_a?(Hash)
          col_name = column.keys.first
          col_options = column.values.first
          array_text << "{\"name\":\"#{col_name}\""
          if col_options[:required]
            array_text << ", \"allowBlank\":false"
          end
          array_text << "},"
        else
          array_text << "{\"name\":\"#{column}\"},"
        end
      end
    else
      model.columns.each do |column|
        array_text << "{\"name\":\"#{column.name}\"},"
      end
    end

    if options[:show_timestamps]
      array_text << "{\"name\":\"created_at\"},"
      array_text << "{\"name\":\"updated_at\"},"
    end

    array_text = array_text[0..array_text.length - 2]

    array_text << "]"

    array_text
  end

end
