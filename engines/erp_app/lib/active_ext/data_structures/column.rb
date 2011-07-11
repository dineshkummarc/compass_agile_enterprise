class ActiveExt::DataStructures::Column
  attr_accessor :name, :association, :column, :options
  
  def initialize(name, active_record_class)
    @name = name.to_sym
    @column = active_record_class.columns_hash[self.name.to_s]
    @association = active_record_class.reflect_on_association(self.name)
    @active_record_class = active_record_class
    @table = active_record_class.table_name
    #set default options
    @options = {:required => false, :readonly => false}
  end

  def sql_type
    @column.type
  end
end