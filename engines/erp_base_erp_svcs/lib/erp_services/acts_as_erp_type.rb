# ActsAsErpType

module ErpServices
  module ActsAsErpType
    def self.included(base)
      base.extend(ClassMethods) 	        	      	
    end

    # declare the class level helper methods which
    # will load the relevant instance methods
    # defined below when invoked
    module ClassMethods

      def acts_as_erp_type
				
        # this is at the class level
        # add any class level manipulations you need here, like has_many, etc.
        extend ActsAsErpType::ActsAsSingletonMethods
        include ActsAsErpType::ActsAsInstanceMethods
				
        # find each valid value for the domain type (erp_type) in question
        # we will then create a class method with the name of the internal idenfifier
        # for that type
        valid_values = self.find(:all)
				
        # the class method will return a populated instance of the correct type
        valid_values.each do | vv |
          (class << self; self; end).instance_eval { define_method vv.internal_identifier, Proc.new{vv} } unless vv.internal_identifier.nil?
        end 
      end

      def belongs_to_erp_type(model_id = nil, options = {})

        @model_id = model_id
        self.belongs_to model_id, options
        extend ActsAsErpType::BelongsToSingletonMethods
        include ActsAsErpType::BelongsToInstanceMethods
				
      end

    end

    # Adds singleton methods.
    module ActsAsSingletonMethods
					  
      def valid_types
        self.find(:all).collect{ |type| type.internal_identifier.to_sym }
      end
		  
      def valid_type?( type_name_string )
        sym_list = self.find(:all).collect{ |type| type.internal_identifier.to_sym }
        sym_list.include?(type_name_string.to_sym)
      end
	  		
      def eid( external_identifier_string )
        find( :first, :conditions => [ 'external_identifier = ?', external_identifier_string.to_s ])
      end
  				
      def iid( internal_identifier_string )
        find( :first, :conditions => [ 'internal_identifier = ?', internal_identifier_string.to_s ])
      end
  			
    end

    module BelongsToSingletonMethods
			
      def fbet( domain_value, options = {})
        find_by_erp_type( domain_value, options )
      end
				
      def find_by_erp_type(domain_value, options = {})
				
        # puts "options...."
        # puts options[:class]
        # puts options[:foreign_key]
				
        erp_type = options[:class] || @model_id
        fk_str = options[:foreign_key] || erp_type.to_s + '_id'
				
        #***************************************************************
        # uncomment these lines for a variety of debugging information
        #***************************************************************
        # klass = self.to_s.underscore + '_type'
        # puts "default class name"
        # puts klass
				
        # puts "model id"
        # puts @model_id
        #
        # puts "finding by erp type"
        # puts "self is: #{self}"
        # puts "type is: #{erp_type}"
				
        # puts "fk_str for in clause..."
        # puts fk_str
				
        type_klass = Kernel.const_get( erp_type.to_s.camelcase )
        in_clause_array = type_klass.send( domain_value.to_sym )
				
        find( :all, :conditions => [ fk_str + ' in (?)', in_clause_array ] )
				
      end

      def fabet( domain_value, options = {} )
        find_all_by_erp_type( domain_value, options )
      end

      def find_all_by_erp_type( domain_value, options = {} )

        erp_type = options[:class] || @model_id
        fk_str = options[:foreign_key] || erp_type.to_s + '_id'
								
        type_klass = Kernel.const_get( erp_type.to_s.camelcase )
        in_clause_array = type_klass.send( domain_value.to_sym ).full_set

        #puts "id for in clause..."
        #id_str = erp_type.to_s + '_id'
				
        find( :all, :conditions => [ fk_str + ' in (?)', in_clause_array ] )
				
      end


				  	  		
    end

		
    # Adds instance methods.
    module ActsAsInstanceMethods
			
      # def instance_method_for_acts_as
      #   puts "Instance with ID #{self.id}"
      # end
		  
    end

    # Adds instance methods.
    module BelongsToInstanceMethods
			
      # def instance_method_for_belongs_to
      #   puts "Instance with ID #{self.id}"
      # end
		  
    end
  end
end

ActiveRecord::Base.send(:include, ErpServices::ActsAsErpType)

