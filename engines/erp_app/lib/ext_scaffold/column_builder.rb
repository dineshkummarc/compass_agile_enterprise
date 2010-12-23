module ExtScaffold::ColumnBuilder

  def self.build_column_from_column_obj(column, options={})
    json_text = nil

    json_text = self.send("build_#{column.type.to_s}_column", column.name, options)

    json_text
  end

  private

 
  def self.build_boolean_column(column_name, options={})
    json = "{
      \"header\":\"#{column_name}\",
      \"type\":\"date\",
      \"dataIndex\":\"#{column_name}\",
      \"width\":150,
      \"renderer\":function(v) {
        result = \"False\";
        
        if(v == 1){
          result = \"True\";
        }
        return result;
      }"

    if options[:readonly].blank? || !options[:readonly]
      json << ",editor:{xtype:\"booleancolumneditor\"}"
    end

    json << '}'

    json
  end
  
  def self.build_date_column(column_name, options={})
    json = "{
      \"header\":\"#{column_name}\",
      \"type\":\"date\",
      \"dataIndex\":\"#{column_name}\",
      \"width\":150,
      \"renderer\":function(v) {
       return v.format('Y-M-D');
      }"

    if options[:readonly].blank? || !options[:readonly]
      json << ",\"editor\":{xtype:\"datefield\"}"
    end

    json << '}'

    json
  end
  
  def self.build_datetime_column(column_name, options={})
    json = "{
      \"header\":\"#{column_name}\",
      \"type\":\"date\",
      \"dataIndex\":\"#{column_name}\",
      \"width\":150,
     \"renderer\":function(v) {
       return Ext.util.Format.date(v,'Y-m-d h:i:s');
      }"

    if options[:readonly].blank? || !options[:readonly]
      json << ",\"editor\":{xtype:\"datefield\"}"
    end

    json << '}'

    json
  end

  def self.build_string_column(column_name, options={})
    json = "{
      \"header\":\"#{column_name}\",
      \"type\":\"string\",
      \"dataIndex\":\"#{column_name}\",
      \"width\":150"

    if options[:readonly].blank? || !options[:readonly]
      json << ",editor:{xtype:\"textfield\"}"
    end

    json << '}'

    json
  end

  def self.build_integer_column(column_name, options={})
    json = "{
      \"header\":\"#{column_name}\",
      \"type\":\"number\",
      \"dataIndex\":\"#{column_name}\",
      \"width\":150"

    if options[:readonly].blank? || !options[:readonly]
      json << ",\"editor\":{xtype:\"numberfield\"}"
    end

    json << '}'
    
    json
  end

  def self.build_decimal_column(column_name, options={})
    json = "{
      \"header\":\"#{column_name}\",
      \"type\":\"float\",
      \"dataIndex\":\"#{column_name}\",
      \"width\":150"

    if options[:readonly].blank? || !options[:readonly]
      json << ",\"editor\":{xtype:\"numberfield\"}"
    end

    json << '}'

    json
  end

  def self.build_float_column(column_name, options={})
    json = "{\"header\":\"#{column_name}\",\"type\":\"float\",\"dataIndex\":\"#{column_name}\",\"width\":150"

    if options[:readonly].blank? || !options[:readonly]
      json << ",\"editor\":{xtype:\"numberfield\"}"
    end

    json << '}'

    json
  end

end
