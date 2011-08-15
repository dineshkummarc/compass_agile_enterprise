module ActiveExt::ExtHelpers::TableBuilder

  def self.generate_columns_and_fields(core)
    columns     = self.build_columns(core)
    fields      = self.build_fields(core)
    validations = self.build_validations(core)

    return columns, fields, validations
  end

  private

  def self.build_columns(core)
    columns = []

    #add id column if showing it
    if core.options[:show_id]
      columns << ActiveExt::ExtHelpers::ColumnBuilder.build_column(core.columns[:id])
    end
    
    #build ext columns
    core.columns.each do |column|
      next if column.name.to_s =~ /(^id|created_at|updated_at)$/ || core.columns.exclude_column?(column.name)
      columns << ActiveExt::ExtHelpers::ColumnBuilder.build_column(column)
    end
    
    #add timestamp columns if showing them
    if core.options[:show_timestamps]
      columns << ActiveExt::ExtHelpers::ColumnBuilder.build_column(core.columns[:created_at])
      columns << ActiveExt::ExtHelpers::ColumnBuilder.build_column(core.columns[:updated_at])
    end
    
    columns
  end

  def self.build_fields(core)
    fields = []

    fields << {:name => 'id', :type => 'number'}

    #build ext fields
    core.columns.each do |column|
      next if column.name.to_s =~ /(^created_at|updated_at)$/  || core.columns.exclude_column?(column.name)
      if column.association.nil?
        fields << {:name => column.name, :allowBlank => !column.options[:required]}
      end
    end

    if core.options[:show_timestamps]
      fields << {:name => 'created_at', :type => 'date'}
      fields << {:name => 'updated_at', :type => 'date'}
    end

    fields
  end

  def self.build_validations(core)
    validations = []

    #build ext fields
    core.columns.each do |column|
      next if column.name.to_s =~ /(^created_at|updated_at)$/  || core.columns.exclude_column?(column.name)
      if column.association.nil?
        if column.options[:required]
          validations << {:type => 'presence', :field => column.name}
        end
      end
    end

    validations
  end

end
