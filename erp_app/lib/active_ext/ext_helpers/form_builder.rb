module ActiveExt::ExtHelpers::FormBuilder
  class << self

    def build_form_fields(core, model_id, action)
      fields = []

      if action != 'new'
        #add hidden id
        fields << ActiveExt::ExtHelpers::FieldBuilder.build_field(core.columns[:id], get_value(core, model_id, :id), false, true)
        #add id column if showing it
        if core.options[:show_id]
          fields << ActiveExt::ExtHelpers::FieldBuilder.build_field(core.columns[:id], get_value(core, model_id, :id), true)
        end
      end

      display_only = action == 'show'

      #build ext columns
      core.columns.each do |column|
        next if column.name.to_s =~ /(^id|created_at|updated_at)$/  || core.columns.exclude_column?(column.name)
        next if column.sql_type.blank? || column.sql_type == NilClass
        fields << ActiveExt::ExtHelpers::FieldBuilder.build_field(column, get_value(core, model_id, column.name), display_only)
      end

      #add timestamp columns if showing them
      if core.options[:show_timestamps] && action != 'new'
        fields << ActiveExt::ExtHelpers::FieldBuilder.build_field(core.columns[:created_at], get_value(core, model_id, :created_at), true)
        fields << ActiveExt::ExtHelpers::FieldBuilder.build_field(core.columns[:updated_at], get_value(core, model_id, :updated_at), true)
      end

      fields.to_json
    end

    def get_value(core, model_id, name)
      value = nil

      unless model_id.nil?
        value = core.model.find(model_id).send(name)
      end

      value
    end

  end
end
