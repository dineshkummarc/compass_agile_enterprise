class ActiveExt::Core
  attr :model_id
  attr_accessor :columns
  attr_accessor :association_names

  #rails generated columns.  Do not remove these
  RAILS_COLUMNS = [:id, :created_at, :updated_at]
  BETTER_NESTED_SET_COLUMNS = [:parent_id, :lft, :rgt]

  def initialize(model_id, options)
    @model_id = model_id.to_s.pluralize.singularize
    @options  = options
    
    #get all attribute columns
    attribute_names = self.model.columns.collect{ |c| c.name.to_sym }.sort_by { |c| c.to_s }

    #only include attribute columns we care about, do not remove rails generated columns
    if options[:only]
      valid_columns = []
      options[:only].each do |option|
        if option.is_a?(Hash)
          valid_columns << option.keys.first
        else
          valid_columns << option
        end
      end
      valid_columns = valid_columns | RAILS_COLUMNS
      attribute_names.delete_if{|item| !valid_columns.include?(item.to_sym)}
    end

    #if we are including associations get them
    unless options[:ignore_associations]
      @association_names = self.model.reflect_on_all_associations.collect{ |a| a.name.to_sym }
      association_column_names = @association_names.sort_by { |c| c.to_s }
      attribute_names += association_column_names
    end

    @columns = ActiveExt::DataStructures::Columns.new(self.model, attribute_names)
    
    #exclude id columns and count columns and better nested set columns
    @columns.exclude(*@columns.find_all { |c| c.column and (c.column.primary or c.column.name =~ /(_id|_count)$/) }.collect {|c| c.name})
    #exclude nested set columns
    @columns.exclude(*@columns.find_all { |c| c.column and (BETTER_NESTED_SET_COLUMNS.include?(c.column.name.to_sym)) }.collect {|c| c.name})
    #exclude associations columns
    @columns.exclude(*self.model.reflect_on_all_associations.collect{|a| :"#{a.name}_type" if a.options[:polymorphic]}.compact)

    set_column_options
  end

  def model_id
    @model_id
  end
  
  def model
    @model ||= @model_id.to_s.camelize.constantize
  end

  def options
    @options
  end

  private

  def set_column_options
    all_column_options = self.options[:only]
    self.columns.each do |column|
      if RAILS_COLUMNS.include?(column.name)
        column.options = {:readonly => true, :required => false}
      else
        unless all_column_options.nil?
          column_options = all_column_options.find{|item| item.is_a?(Hash) && item.has_key?(column.name)}
          unless column_options.nil?
            column.options = column_options[column.name]
          end
        end
      end
    end
  end

end