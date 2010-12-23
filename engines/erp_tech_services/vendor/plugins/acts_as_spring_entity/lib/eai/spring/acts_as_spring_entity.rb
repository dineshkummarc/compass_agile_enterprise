# ActsAsSpringEntity
require 'rjb' # require the ruby-java-bridge

# This plugin allows ActiveRecord models to provide a facade
# to java/spring entities. Refer to the README for more details

module Eai::Spring
  module ActsAsSpringEntity
    # Lazy loading.
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      unloadable

      # you must supply the following
      # :factory_class  - the fully qualified bean factory class name
      # :dao_accessor   - the bean factory method name that retrieves the dao instance
      # :entity_model- the fully qualified hibernate model name
      def acts_as_spring_entity(configuration ={})
        configuration[:factory_class]||=nil
        configuration[:entity_model]||=nil
        configuration[:dao_accessor]||=nil
        Rails.logger.info("test params")
        if(configuration[:factory_class]==nil)
          raise ":factory_class was not supplied"
        end
        if(configuration[:entity_model]==nil)
          raise ":entity_model was not supplied"
        end
        if(configuration[:dao_accessor]==nil)
          raise ":dao_accessor was not supplied"
        end
        Rails.logger.info "Adding acts_as_spring_entity behaviors"
#        Rails.logger.info "setting bean factory to:#{configuration[:factory_class]}"
#        Rails.logger.info "hibernate model:#{configuration[:dao_accessor]}"
#        Rails.logger.info "hibernate model:#{configuration[:entity_model]}"
        #unless included_modules.include? InstanceMethods
        
        class_inheritable_accessor :configuration, :factory_class,:entity_model
        
        extend Eai::Spring::ActsAsSpringEntity::SingletonMethods
        include Eai::Spring::ActsAsSpringEntity::InstanceMethods
        #end
        self.configuration=configuration
      end

    end


    module SingletonMethods
      # provide access to the target spring bean factory as a singleton instance
      def bean_factory
        Rails.logger.info "getting bean factory #{configuration[:factory_class] }"
        if(@bean_factory_instance==nil)
          @bean_factory_instance=Rjb::import(configuration[:factory_class]).new
          Rails.logger.info "created bean factory #{@bean_factory }"
        end
        return @bean_factory_instance

      end

      # provide access to the target spring dao as a singleton instance
      def dao
        if(@dao ==nil)
          dao_accessor_method=configuration[:dao_accessor].to_sym
          Rails.logger.info "obtaining dao #{dao_accessor_method}"
          @dao=bean_factory.send(dao_accessor_method)
        end
        Rails.logger.info("dao: #{@dao}")
        return @dao

      end

      # return the name of the configured entity model
      def entity_model
        return configuration[:entity_model]
      end
      # return the name of the configured dao accessor method
      def dao_accessor_name
        return configuration[:dao_accessor]
      end
      # return the name of the configured bean factory class
      def bean_factory_class_name
        return configuration[:factory_class]
      end

      # when a an instance of spring entity model is returned
      # wrap it with a new model
      def new_model_from_instance(  _instance)
        new_model=new
        Rails.logger.info "result->#{  _instance.toString()}"
        new_model.instance= _instance

        if(_instance ==nil)

          Rails.logger.info("spring entity _instance is NIL")
        end

        return new_model
      end


      # provide basic finder features
      # TODO support options
      def find(*args)
        Rails.logger.info("find called (#{args})")
        options = args.extract_options!
        validate_find_options(options)
        set_readonly_option!(options)

        case args.first
        when :first then find_initial(options)
        when :last  then find_last(options)
        when :all   then find_every(options)
        else             find_from_ids(args, options)
        end
      end


      # find the first instance
      # TODO support options
      def find_initial(options)
        if(options==nil)
          results=dao.find("from #{configuration[:entity_model]}",0,1)
        else
          # needs a custom where clause
          results=dao.find("from #{configuration[:entity_model]}",0,1)
        end
        if(results ==nil)
          return nil
        end
        # convert the resulting array to an array of models
        result_array= convert_instance_to_model(results.toArray())
        if(result_array.length >0)
          return result_array[0]
        else
          return nil
        end
      end

      # find the last instance
      # TODO
      def find_last(options)
        raise 'find_last method not implemented'
      end

      # find all instance
      # TODO option
      def find_every(options)
        if(options==nil)
          results=dao.find("from #{configuration[:entity_model]}",0,0)
        else
          # needs a custom where clause
          results=dao.find("from #{configuration[:entity_model]}",0,0)
        end
        if(results ==nil)
          return nil
        end
        # convert the resulting array to an array of models
        return convert_instance_to_model(results.toArray())

      end

      # finders return arrays of spring entities that need
      # to be wrapped with the corresponding model
      def convert_instance_to_model(array)
        model_array=Array.new
        array.each do |instance|
          model_array << new_model_from_instance(instance)
        end
        return model_array
      end

      # find by id's
      # TODO support options
      def find_from_ids(args,options)
        #Rails.logger.info
        Rails.logger.info ("find_from_ids #{args}")
        id_list=""
        # must supply a valid arg
        if(args !=nil)
          # check if args is an array if so flatten it
          #          if(args.is_a?)
          #            args.each do |arg|
          #              id_list << "#{arg},"
          #            end
          #            #remove the last ,
          #            id_list=args[0,args.length-1]
          #          else
          # args is a single value
          id_list=args
          #          end
          Rails.logger.info  "ids:#{id_list}"
          query="from #{configuration[:entity_model]} where id IN (#{id_list})"
          Rails.logger.info  query
          if(options==nil)
            results=dao.find(query,0,0)
          else
            # needs a custom where clause
            results=dao.find(query,0,0)
          end
          if(results ==nil)
            return nil
          end
          # convert the resulting array to an array of models
          result_array= convert_instance_to_model(results.toArray())
          if(result_array.length >0)
            return result_array[0]
          else
            return nil
          end

        else
          return nil
        end
      end


      # find first convenience method
      def first(*args)
        find(:first,*args)
      end

      # find last convenience method
      def last(*args)
        find(:last,*args)
      end

      # find all convenience method
      def all(*args)
        find(:all,*args)
      end

      def create(attributes = nil)
        raise "ActsAsSpringEntity Unsupported Feature"
      end

      def delete(id)
        raise "ActsAsSpringEntity Unsupported Feature"
      end

      def delete_all(conditions = nil)
        raise "ActsAsSpringEntity Unsupported Feature"
      end
      def destroy(id)
        raise "ActsAsSpringEntity Unsupported Feature"
      end

      def destroy_all(conditions = nil)
        raise "ActsAsSpringEntity Unsupported Feature"
      end

      def exists?(id_or_conditions ={})
        raise "ActsAsSpringEntity Unsupported Feature"
      end

       
    end

    module InstanceMethods
      
      

      # created an instance of the model as well
      # as its spring entity backing object
      def initialize(attributes = nil)
        super(attributes)
        Rails.logger.info("configuration:#{ configuration}")
        @_instance=Rjb::import(configuration[:entity_model]).new

      end


      def delete
        destroy
      end
      
      def destroy
        klass = Kernel.const_get self.class.to_s
        this_dao=klass.send(:dao)
        this_dao.delete(@_instance)

      end

      # return the underlying spring entity backing instance
      def instance
        return @_instance
      end

      # set the underlying spring entity backing instance

      def instance=(obj)
        @_instance=obj
      end


      # use the java reflection api to find the accessor and mutator methods
      # declared in the spring entity model ('get', 'set' prefixes) and set
      # them in the corresponding class vars
      def get_accessors_and_mutators
        @accessors=Array.new
        @mutators=Array.new
        Rails.logger.info  "bean factory: #{@_instance}"
        methods=@_instance.getClass().getDeclaredMethods()
        methods.each do |method|
          method_name= method.getName()
          if(method_name.start_with?("get"))
            @accessors<< method_name[3,method_name.length].gsub(/[A-Z]+/,'\1_\0').downcase[1..-1] # camelcase to ruby_underscore

          elsif(method_name.start_with?("set"))
            @mutators<< method_name[3,method_name.length].gsub(/[A-Z]+/,'\1_\0').downcase[1..-1]# camelcase to ruby_underscore

          end
          
        end
        Rails.logger.info  "accessors #{@accessors}"
        Rails.logger.info  "mutators #{@mutators}"
      end


      def method_missing(method, *args)
        method_name=method.to_s
        Rails.logger.info  "checking for method #{method_name}"

        # perform the reflection on first call only
        if((@accessors ==nil) || (@mutators==nil))
          get_accessors_and_mutators
        end

        # check if a mutator
        if(method_name.ends_with?("="))
          Rails.logger.info  "checking mutators"
          @mutators.each do|mutator|
            Rails.logger.info ("testing mutator:#{mutator} ")
            if((mutator+"=")==method_name)
              Rails.logger.info  "found mutator #{mutator}"
              invokeMethod="set#{camel_case(mutator)}"
              Rails.logger.info  "invoke:#{invokeMethod}(#{args})"
              return @_instance.send(invokeMethod.to_sym ,args[0])

            end
          end
        else
          Rails.logger.info  "checking accessors"
          @accessors.each do|accessor|
            Rails.logger.info  ("testing accessor:#{accessor} ")
            if(accessor==method_name)
              Rails.logger.info  "found accessor#{accessor}"
              invokeMethod="get#{camel_case(accessor)}"
              Rails.logger.info  "invoke:#{invokeMethod}()"
              return @_instance.send(invokeMethod.to_sym)
            end
          end

        end

      end

      # convert the snake case to camel case
      def camel_case(str)
        return str if str !~ /_/ && str =~ /[A-Z]+.*/
        str.split('_').map { |i| i.capitalize }.join
      end



      def human_name(options ={})
        raise "ActsAsSpringEntity Unsupported Feature"
      end

      # TODO support validations
      def save(perform_validation = true)

        # insert validation code here

        #now call the save
        klass = Kernel.const_get self.class.to_s
        this_dao=klass.send(:dao)
        this_dao.save(@_instance)
      end

      def save!()
        # call the spring save
        save(true)
      end

      #TODO
      def to_param()
        raise "ActsAsSpringEntity Unsupported Feature"
      end


      # Not called when using ActiveRecord::BaseWithoutTable
      #TODO verify that this will work with ActiveRecord::Base
      def table_exists?()
        # force true -even though we dont use the local
        return true
      end

      #TODO
      def update_attribute(name, value)
        raise "ActsAsSpringEntity Unsupported Feature"
      end
      #TODO
      def update_attributes(attributes)
        raise "ActsAsSpringEntity Unsupported Feature"
      end
      #TODO
      def update_attributes!(attributes)
        raise "ActsAsSpringEntity Unsupported Feature"
      end
      #TODO
      def update (id, attributes)
        raise "ActsAsSpringEntity Unsupported Feature"
      end
      #TODO
      def update_all(updates, conditions =nil, options={})
        raise "ActsAsSpringEntity Unsupported Feature"
      end

       

      
    end
  end

end
