class ErpServices::Products::Catalog
  attr_accessor :values_hash

  def initialize(product_type)
    self.values_hash = {}
    @product_type = product_type
  end

  def [](key)
    self.values_hash[key]
  end

  def []=(key, *args)
    self.values_hash[key] = args[0]
  end

  def method_missing(name, *args, &block)
    if block_given?
      self.values_hash[name] = block.call(@product_type)
    elsif name.to_s.include?('=')
      name = name.to_s.gsub('=','').to_sym
      self.values_hash[name] = @product_type.send(name)
    elsif self.values_hash.has_key?(name)
      return self.values_hash[name]
    else
      super method_missing(name, *args)
    end
  end
   
end

module ErpServices::Products
	module ActsAsProductType

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods

  		def acts_as_product_type(&block)

        has_one :product_type, :as => :product_type_record


        attr_accessor :catalog

        @@catalog_block = block_given? ? block : nil
  		  
        [:children, :description, :description=].each do |m| delegate m, :to => :product_type end

        module_eval do
          def after_initialize
            if self.new_record? && self.product_type.nil?
              product_type = ProductType.new
              self.product_type = product_type
              product_type.product_type_record = self
            end

            unless @@catalog_block.nil?
              self.catalog = ErpServices::Products::Catalog.new(self)
              @@catalog_block.call(self.catalog)
              self.catalog.description
            end
          end
        end

        extend ErpServices::Products::ActsAsProductType::SingletonMethods
			  include ErpServices::Products::ActsAsProductType::InstanceMethods

        def self.find_roots
          ProductType.find_roots
        end

        def self.find_children(parent_id = nil)
          ProductType.find_children(parent_id)
        end
			  			  							     		
		  end

		end
  		
		module SingletonMethods	
		end
				
		module InstanceMethods
      def after_create
        self.product_type.save
      end

      

      def after_update
        self.product_type.save
      end
        
      def after_destroy
        if self.product_type && !self.product_type.frozen?
          self.product_type.destroy
        end
      end

	  end
					
  end
  		
end

ActiveRecord::Base.send(:include, ErpServices::Products::ActsAsProductType)