module ActiveRecord
  class BaseWithoutTable < Base
    self.abstract_class = true
    
    def create_or_update
      errors.empty?
    end
    
    class << self
      def columns()
        @columns ||= []
      end
      
      def column(name, sql_type = nil, default = nil, null = true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        reset_column_information
      end
      
      # Do not reset @columns
      def reset_column_information
        generated_methods.each { |name| undef_method(name) }
        @column_names = @columns_hash = @content_columns = @dynamic_methods_hash = @read_methods = nil

      end
      ## added by cdw
#      def find(*args)
#        options = extract_options_from_args!(args)
#        validate_find_options(options)
#        set_readonly_option!(options)
#
#        case args.first
#        when :first then find_initial(options)
#        when :all   then find_every(options)
#        else find_from_ids(args, options)
#        end
#      end
    end
  end
end
