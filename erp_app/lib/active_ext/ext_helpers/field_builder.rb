module ActiveExt
module ExtHelpers
module FieldBuilder
  class << self

    def build_field(column, value, display_only = false, hidden = false)
      if display_only
        field_json = display_field(column.options)
      elsif hidden
        field_json = hidden_field(column.options)
      elsif column.options[:readonly]
        field_json = display_field(column.options)
      else
        field_json = self.send("build_#{column.sql_type.to_s}_field", column.options)
      end
      
      field_json[:fieldLabel] = column.name.to_s.humanize
      field_json[:name] = column.name.to_s
      field_json[:allowBlank] = !column.options[:required]

      if display_only
        value = format_display_value(column, value)
      elsif column.options[:readonly]
        value = format_display_value(column, value)
      end

      field_json[:value] = value

      field_json
    end

    def format_display_value(column, value)
      if column.sql_type.to_s == 'date'
        value = value.strfdate('%m/%d/%Y') unless value.nil?
      elsif column.sql_type.to_s == 'datetime'
        value = value.strftime('%m/%d/%Y') unless value.nil?
      end

      value
    end

    def hidden_field(options={})
      field_json = {
        :xtype => 'hidden'
      }

      field_json
    end

    def display_field(options={})
      field_json = {
        :width => 250,
        :xtype => 'displayfield',
        :labelWidth => 140
      }

      field_json
    end

    def build_boolean_field(options={})
      field_json = {
        :width => 250,
        :xtype => 'combo',
        :labelWidth => 140,
        :forceSelection => true,
        :store => [['true','True'],['false','False']],
        :triggerAction => 'all'
      }

      field_json
    end

    def build_date_field(options={})
      field_json = {
        :width => 250,
        :xtype => 'datefield',
        :labelWidth => 140
      }

      field_json
    end

    def build_datetime_field(options={})
      field_json = {
        :width => 150,
        :xtype => 'datefield',
        :labelWidth => 140
      }

      field_json
    end

    def build_string_field(options={})
      field_json = {
        :width => 250,
        :xtype => 'textfield',
        :labelWidth => 140
      }

      field_json
    end

    def build_integer_field(options={})
      field_json = {
        :width => 250,
        :xtype => 'numberfield',
        :labelWidth => 140
      }

      field_json
    end

    def build_decimal_field(options={})
      field_json = {
        :width => 250,
        :xtype => 'numberfield',
        :labelWidth => 140
      }

      field_json
    end

    def build_float_field(options={})
      field_json = {
        :width => 250,
        :xtype => 'numberfield',
        :labelWidth => 140
      }

      field_json
    end

    def build_text_field(options={})
      field_json = {
        :width => 150,
        :xtype => 'textarea',
        :labelWidth => 140
      }

      field_json
    end

  end
end
end
end