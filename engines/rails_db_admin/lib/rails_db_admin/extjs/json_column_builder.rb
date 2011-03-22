# To change this template, choose Tools | Templates
# and open the template in the editor.

class RailsDbAdmin::Extjs::JsonColumnBuilder

  def self.build_readonly_column(column_name)
    json_text = nil

    json_text = "{
      header:\"#{column_name}\",
      type:\"string\",
      dataIndex:\"#{column_name}\",
      width:150
     }"

    json_text
  end

  def self.build_column_from_column_obj(column)
    json_text = nil

    json_text = self.send("build_#{column.type.to_s}_column", column.name)

    json_text
  end

  private

 
  def self.build_boolean_column(column_name)
    json = "{
      header:\"#{column_name}\",
      type:\"date\",
      dataIndex:\"#{column_name}\",
      width:150,
      renderer:function(v) {
        result = \"False\";
        
        if(v == 1){
          result = \"True\";
        }
        return result;
      },"

    json += "editor:{xtype:\"booleancolumneditor\"}"

    json += "}"

    json
  end
  
  def self.build_date_column(column_name)
    json = "{
      header:\"#{column_name}\",
      type:\"date\",
      dataIndex:\"#{column_name}\",
      width:150,"

    if column_name != "created_at" && column_name != "updated_at"
      json += "editor:{xtype:\"textfield\"}"
    end

    json += "}"

    json
  end
  
  def self.build_datetime_column(column_name)
    json = "{
      header:\"#{column_name}\",
      type:\"date\",
      dataIndex:\"#{column_name}\",
      width:150,"

    if column_name != "created_at" && column_name != "updated_at"
      json += "editor:{xtype:\"textfield\"}"
    end

    json += "}"

    json
  end

  def self.build_string_column(column_name)
    "{
      header:\"#{column_name}\",
      type:\"string\",
      dataIndex:\"#{column_name}\",
      width:150,
      editor:{xtype:\"textfield\"}
     }"
  end

  def self.build_text_column(column_name)
    "{
      header:\"#{column_name}\",
      type:\"string\",
      dataIndex:\"#{column_name}\",
      width:150,
      editor:{xtype:\"textfield\"}
     }"
  end

  def self.build_integer_column(column_name)
    json = "{
      header:\"#{column_name}\",
      type:\"number\",
      dataIndex:\"#{column_name}\",
      width:150,"

    if column_name != "id"
      json += "editor:{xtype:\"textfield\"}"
    end

    json += "}"

    json
  end

  def self.build_decimal_column(column_name)
    json = "{
      header:\"#{column_name}\",
      type:\"float\",
      dataIndex:\"#{column_name}\",
      width:150,"

    if column_name != "id"
      json += "editor:{xtype:\"textfield\"}"
    end

    json += "}"

    json
  end

  def self.build_float_column(column_name)
    json = "{
      header:\"#{column_name}\",
      type:\"float\",
      dataIndex:\"#{column_name}\",
      width:150,"

    if column_name != "id"
      json += "editor:{xtype:\"textfield\"}"
    end

    json += "}"

    json
  end

end
