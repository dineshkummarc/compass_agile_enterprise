# ActsAsJavaValueObject
# adds support for converting between an ActiveRecord and a Java Value Object

require 'rjb'
module ActsAsJavaValueObject

  # Lazy loading.
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    # refer to the readme for the structure of the configuration object
    def acts_as_java_value_object(configuration ={})
      Rails.logger.info("configuration parameters:#{configuration}")

      configuration[:java_model]||=nil

      if(configuration[:java_model]==nil)
        raise ":java_model was not supplied"
      end

      #unless included_modules.include? InstanceMethods
      Rails.logger.debug "Adding acts_as_drools behaviors"
      class_inheritable_accessor :configuration

      unless included_modules.include? ActsAsJavaValueObject::InstanceMethods
        extend ActsAsJavaValueObject::SingletonMethods
        include ActsAsJavaValueObject::InstanceMethods
      end

      self.configuration=configuration
      #end

      
    end

  end
  module SingletonMethods

    # no singleton methods are added
  end

  module InstanceMethods

    def initialize(attributes = nil)
      super(attributes)
      
    end

    def java_model_name
      return configuration[:java_model]
    end

    # this should probably be deprecated
    def java_instance
      return @java_instance
    end


    def to_java(parent=self,config=configuration)
      Rails.logger.debug("Called to_java on :#{parent.class}")
      Rails.logger.debug("Called to_java with config :#{config}")
      # call the graph to build the root node using the current AR model
      # as the root
      return create_java_graph(parent,config)

    end

    # create_java_graph is responsible for building the java object graph defined in the
    # configuration object of this plugin. It recursively calls itself to build child
    # objects defined in the :include parameter. Each :include entry provides the config
    # parameter to subseqent recursive calls
    
    def create_java_graph(parent,config)
      attribute_name=config[:attribute_name]
      java_model_name=config[:java_model]
      java_model_instance=Rjb::import(java_model_name).new
      java_model_instance.setARModelName(parent.class.to_s)
      exclude_attribute_array=config[:exclude_attribute]
      map_attribute_to_java_method_hash=config[:map_attribute_to_java_method]
      map_method_to_java_method_array=config[:map_method_to_java_method]
      include_array=config[:include]
      log_hr
      Rails.logger.debug("Parent AR Model..................:#{parent.class}")
      Rails.logger.debug("java_model_name_name.............:#{java_model_name}")
      Rails.logger.debug("created java_model_instance......:#{java_model_instance.getClass().toString()}")
      Rails.logger.debug("attribute_name...................:#{attribute_name}")
      Rails.logger.debug("exclude_attribute_array..........:#{exclude_attribute_array}")
      Rails.logger.debug("map_attribute_to_java_method_hash:#{map_attribute_to_java_method_hash}")
      Rails.logger.debug("map_method_to_java_method_array..:#{map_method_to_java_method_array}")
      Rails.logger.debug("include_array....................:#{include_array}")
      log_hr

      ######################################## 
      # set current java instance attributes #
      ########################################

      #assign_attributes_to_java_model_instance(java_model_instance,ar_model,exclude_attribute_array)
      #assign_attributes_to_java_model_instance(java_model_instance,parent,exclude_attribute_array,map_attribute_to_java_method_hash)

      attribute_hash=attributes_only(parent,exclude_attribute_array)
      log_hr
      Rails.logger.debug("#{parent}-attributes:#{attribute_hash}")

      # loop over the attribute hash and set the corresponding java value
      attribute_hash.each_pair do |key, value|
        log_hr
        Rails.logger.debug("ATTRIBUTE..:#{key}")
        Rails.logger.debug("VALUE TYPE.:#{value.class.to_s}")
        # convert ruby 'primitives' to java primitives
        log_hr
        # handle FalseClass
        # convert to a java boolean primitive
        if(value.class.to_s=="FalseClass")
          java_value=(Rjb::import("java.lang.Boolean").FALSE).booleanValue()
          # handle TrueClass
          # convert to a java boolean primitive
        elsif(value.class.to_s=="TrueClass")
          java_value=(Rjb::import("java.lang.Boolean").TRUE).booleanValue()
          # handle Time & Date
        elsif((value.class.to_s=="Time")|| (value.class.to_s=="Date"))
          # convert the time or date to a java object
          # Both Time and Date create java.util.Date instances.
          # Time will populate the year,month and date.
          # Date does not populate hr,minute, seconds
          
          rails_date_formatted=value.strftime("%Y/%m/%d %H:%M:%S")
          Rails.logger.debug(">Converted Rails time to :(#{rails_date_formatted})")
          java_simple_date_format=Rjb::import("java.text.SimpleDateFormat").new("yyyy/MM/dd HH:mm:ss")
          java_date_parsed=java_simple_date_format.parse(rails_date_formatted)
          Rails.logger.debug(">Parsed Rails time time to :(#{java_date_parsed.toString}")
          log_hr

          java_value=java_date_parsed

        else
          java_value=value
        end

        # check if this attribute requires a method name remapping
        # NOTE: normally the java method name is generated by
        # CamelCasing the attribute name and adding the prefix 'set'
        # to conform to standard java mutator naming convention. Remapping
        # allows explicit declaration of the java method that will be invoked
        # when the attribute is being set.

        # check if we hava to remap the attribute to a different mutator
        if(map_attribute_to_java_method_hash !=nil)
          remapped_attribute=map_attribute_to_java_method_hash[key.to_s]
        else
          remapped_attribute=nil
        end

        #if remap
        if(remapped_attribute !=nil)
          #puts "Remapped attribute [#{key}] to [#{remapped_attribute}]"
          # set the java mutator method name to the remapped value
          java_method_name=remapped_attribute
        else
          # puts "no remapping needed for [#{key}]"
          #the convention is to call the java set(attribute) mutator
          #convert the AR attribute to the java camelcase and prefix with set
          java_method_name="set"+camel_case(key.to_s)
        end

        log_hr
        # we dont invoke when the value in nul
        if(java_value==nil)

          Rails.logger.debug("Skipping attribute(#{key}) setting- value == nil")

        else

          Rails.logger.debug "#INVOKE class-->#{java_model_instance.toString()}"
          Rails.logger.debug "        method->#{java_method_name}"
          Rails.logger.debug "     with value(#{java_value})"
          java_model_instance.send(java_method_name.to_sym,java_value)

        end
        log_hr
      end
     

      #########################################################
      # set any values declared by :map_method_to_java_method #
      #########################################################

      if(map_method_to_java_method_array !=nil)
        # loop over the include array to get the included association hashes
        map_method_to_java_method_array.each do |map_method_hash|
          #:method=>"inv_item",:java_method=>"setInvItem",:java_model=>"com.tnsolutionsinc.compass.erp.models.AccommodationInvItem"
          ar_method=map_method_hash[:method]
          java_method=map_method_hash[:java_method]
          # if the java_method is not explicitly defined 
          # CamelCase the method name and prefix it with 'set' 
          # and use it as the mutator method name
          if(java_method ==nil)
            java_method="set"+camel_case(ar_method.to_s)
          end
          map_java_model=map_method_hash[:java_model]
          map_java_model_instance=Rjb::import(map_java_model).new
          log_hr
          Rails.logger.debug("AR method...........: #{ar_method}")
          Rails.logger.debug("AR method type......: #{ar_method.class.to_s}")
          Rails.logger.debug("java method.........: #{java_method}")
          Rails.logger.debug("java model..........: #{map_java_model}")
          Rails.logger.debug("java model instance.: #{map_java_model_instance.getClass().toString()}")
          log_hr

          target_ar_model = parent.send(ar_method.to_sym)
          Rails.logger.debug("method value......: #{target_ar_model}")
          Rails.logger.debug("method value class: #{target_ar_model.class}")
          log_hr
          if(target_ar_model.is_a? ActiveRecord::Base)
            #java_value=assign_attributes_to_java_model_instance(map_java_model_instance,target_ar_model,[]) #TODO replace the null array with a real exclude_attribute array
            #java_model_instance.send(java_method.to_sym,java_value)
          else
            # handle setting primitives
          end
        end

      end
      ################################################
      # set any associations defined by the :include #
      ################################################

      if (include_array != nil)
        # loop over the include array to get the included association hashes
        include_array.each do |included_association|

          Rails.logger.debug("included association: #{included_association}")
          # get then name of the association attribute
          include_attribute_name=included_association[:attribute_name]
          # call the association pointed to by the include_attribute_name 's accessor
          include_ar_parent= parent.send(include_attribute_name.to_sym)
          # make the recursive call to create the sub-graph
          include_java_instance=create_java_graph(include_ar_parent,included_association)
          
          #get the vo mutator for the association
          included_vo_mutator=included_association[:map_attribute_to_method]
          if(included_vo_mutator == nil)
            #no explicit mutator was defined so use the default
            included_vo_mutator=create_java_mutator_name(include_attribute_name)
          end
          #now set the subtree on the current level VO
          Rails.logger.debug("#{parent.class}.send(#{included_vo_mutator} , #{include_java_instance.getClass().toString()})")

          # allow remapping of the java method that gets invoked
          alternate_mapped_mutator=included_association[:java_method]

          if(alternate_mapped_mutator!=nil)
            Rails.logger.debug("association remapped VO mutator:#{alternate_mapped_mutator}")
            included_vo_mutator=alternate_mapped_mutator
            ## need to change the accessor to a mutator
            included_vo_mutator[0]='s' #TODO this hack forces the mutator first char to s incase it was modified
            # need to fix this
          end
          log_hr
          Rails.logger.debug("java_model_instance:#{java_model_instance}")
          Rails.logger.debug("included_vo_mutator:#{included_vo_mutator}")
          Rails.logger.debug("include_java_instance:#{include_java_instance}")
          Rails.logger.debug("java_model_instance class:#{java_model_instance.getClass().getName()}")
          Rails.logger.debug("include_java_instance: class#{include_java_instance.getClass().getName()}")
          java_model_instance.send(included_vo_mutator.to_sym,include_java_instance)
          log_hr
        end
      end
      log_hr
      if (parent ==self)
        Rails.logger.debug("Created ROOT model")
        # set the root java instance
        @java_instance=java_model_instance
      else
        Rails.logger.debug("Created child model")
        #{:attribute_name=>"xyz", :java_model=>"xyzmodel", :exclude_attribute=>"created_at","updated_at",:map_attribute_to_method=>{"attribute_name",setXXXmethod"},:include=>[]
      end

      Rails.logger.debug("Populated Java Instance:#{java_model_instance.toString()}")
      log_hr
      return java_model_instance
    end

    # this just logs a horizontal rule to separate blocks of log output
    def log_hr
      Rails.logger.debug "---------------------------------------------------------------------------------------------------------------------------------"
    end

    #
    def assign_attributes_to_java_model_instance(java_model_instance,ar_model,exclude_attribute_array,map_attribute_to_java_method_hash)

      attribute_hash=attributes_only(ar_model,exclude_attribute_array)
      log_hr
      Rails.logger.debug("#{ar_model}-attributes:#{attribute_hash}")
      log_hr
      # loop over the attribute hash and set the corresponding java value
      attribute_hash.each_pair do |key, value|
        Rails.logger.debug ">>Value Type: #{value.class.to_s}"
        log_hr

        # convert ruby 'primitives' to java primitives
        #handle FalseClass
        if(value.class.to_s=="FalseClass")
          java_value=(Rjb::import("java.lang.Boolean").FALSE).booleanValue()

        elsif(value.class.to_s=="TrueClass")
          java_value=(Rjb::import("java.lang.Boolean").TRUE).booleanValue()
        else
          java_value=value
        end

        # check if this attribute requires a method name remapping
        # NOTE: normally the java method name is generated by
        # CamelCasing the attribute name and adding the prefix 'set'
        # to conform to standard java mutator naming convention. Remapping
        # allows explicit declaration of the java method that will be invoked
        # when the attribute is being set.

        # check if we hava to remap the attribute to a different mutator
        # need to support remapping of values
        remapped_attribute=map_attribute_to_java_method_hash[key.to_s]

        #if remap
        if(remapped_attribute !=nil)
          #puts "Remapped attribute [#{key}] to [#{remapped_attribute}]"
          # set the java mutator method name to the remapped value
          java_method_name=remapped_attribute
        else
          # puts "no remapping needed for [#{key}]"
          #the convention is to call the java set(attribute) mutator
          #convert the AR attribute to the java camelcase and prefix with set
          java_method_name="set"+camel_case(key.to_s)
        end

        if(java_value==nil)
          Rails.logger.debug("Skipping attribute(#{key}) setting- value == nil")
        else
          Rails.logger.debug "INVOKE class..:#{java_model_instance.toString()}"
          Rails.logger.debug "method........:#{java_method_name}"
          Rails.logger.debug "with value....:(#{java_value})"

          java_model_instance.send(java_method_name.to_sym,java_value)
        end
      end
      log_hr
    end

    ## create a hash containing only attribute and attribute values
    ## without including the association _ids
    def attributes_only(object,exclude_attribute_array=[])
      attribute_hash=Hash.new
      attributes=object.attributes
      attributes.each_pair do |key, value|
        if((key.ends_with?("_id")) )
          # skip over the association attributes
          Rails.logger.debug("Excluding association attribute.:#{key}")
        elsif ((exclude_attribute_array!=nil) &&( exclude_attribute_array.include?(key)))
          # and any explicit attribute exclusions
          Rails.logger.debug("Excluding attribute.............:#{key}")
        else
          attribute_hash[key]=value
        end
      end
      return attribute_hash

    end

    # create a hash containing only the associations
    def associations_only(object,exclude_attribute_array)
      associations_hash=Hash.new
      attributes=object.attributes
      attributes.each_pair do |key, value|
        if((key.ends_with?("_id")) )
          Rails.logger.debug("adding association :#{key}")
          association_hash[key]=value
        end
      end
      return associations_hash

    end
   
    # helper method to create a standard java
    # mutator name from a snake_cased string
    def create_java_mutator_name(str)
      return "set"+camel_case(str)
    end

    # helper method to create a standard java
    # accessor name from a snake_cased string
    def create_java_accessor_name(str)
      return "get"+camel_case(str)
    end

    # convert a snake_case string to CamelCase
    def camel_case(str)
      return str if str !~ /_/ && str =~ /[A-Z]+.*/
      retval=""
      str.split('_').map do |i|
        d=i.capitalize

        retval<< d

      end
      return retval
    end

    # this can  be removed
    def accessors_mutators_hash
      reject_methods = ["==","===","[]=","taguri=","unsaved=","configuration=","attributes="]
      allmethods=self.methods.sort
      result_hash = Hash.new
      mutators = Array.new
      accessors = Array.new
      allmethods.each do |m|
        # find all mutators
        if ((m.ends_with?("="))  )
          # we want to exclude the _id
          if((m.end_with?("_id=")) || (m.end_with?("_ids=")))
            #puts "REJECT _id :#{m}"
          else
            if(reject_methods.include?(m))
              # skip the excluded methods
            else
              mutators << m # add the mutator to the mutator array
              accessors << m[0,m.length-1] # strip the = and add the accessor
            end
          end
          
        end
        
      end
      result_hash[:accessors]=accessors
      result_hash[:mutators]=mutators
      return result_hash
    end

    # uses the configuration data to repopulate the
    # active record model from the java_value_object instance
    def update_model_from_java_value_object(java_value_object)
      Rails.logger.debug("Updating Active Record model #{self} from java value object #{java_value_object.getClass().toString()}")

      populate_active_record_model_from_java_value_object(nil,java_value_object,configuration)

    end

    # find the active record model that corresponds to the java value object
    # Note: this method does not populate the active record model
    def create_default_active_record_model_from_java_value_object(java_value_object)
      ar_model_name=java_value_object.getARModelName()
      ar_model_id=java_value_object.getId()

      Rails.logger.debug "convert java vo to ar model"
      Rails.logger.debug "ar model name    :#{ar_model_name}"
      Rails.logger.debug "ar model id      :#{ar_model_id}"
      ar_model_class = Kernel.const_get(ar_model_name)
      Rails.logger.debug "ar model class   :#{ar_model_class}"
      ar_model_instance=ar_model_class.find(ar_model_id)
      Rails.logger.debug "ar model instance   :#{ar_model_instance}"
      return ar_model_instance
    end

    # populates the supplied active record model (parent) with values from the
    # supplied java_value_object. This method uses the config to determine the
    # mapping of java value object fields to the active record model
    def populate_active_record_model_from_java_value_object(parent,java_value_object, config)
      log_hr
      if (parent ==nil)
        parent=self
      else
        parent = create_default_active_record_model_from_java_value_object(java_value_object)
      end

      Rails.logger.debug("populate_active_record_model_from_java_value_object")

      attribute_name=config[:attribute_name]

      exclude_attribute_array=config[:exclude_attribute]
      map_attribute_to_java_method_hash=config[:map_attribute_to_java_method]
      map_method_to_java_method_array=config[:map_method_to_java_method]
      include_array=config[:include]

      Rails.logger.debug("Parent AR Model..................:#{parent.class}")
      Rails.logger.debug("java_model_name_name.............:#{java_value_object}")

      Rails.logger.debug("attribute_name...................:#{attribute_name}")
      Rails.logger.debug("exclude_attribute_array..........:#{exclude_attribute_array}")
      Rails.logger.debug("map_attribute_to_java_method_hash:#{map_attribute_to_java_method_hash}")
      Rails.logger.debug("map_method_to_java_method_array..:#{map_method_to_java_method_array}")
      Rails.logger.debug("include_array....................:#{include_array}")


      attribute_hash=attributes_only(parent,exclude_attribute_array)

      Rails.logger.debug("#{parent}-attributes:#{attribute_hash}")

      # loop over the attribute hash (ignoring its value)
      # and get the java value objects corresponding value
      attribute_hash.each_pair do |key, value|
        log_hr
        Rails.logger.debug("ATTRIBUTE..:#{key}")

        # check if this attribute requires a method name remapping
        # NOTE: normally the java method name is generated by
        # CamelCasing the attribute name and adding the prefix 'set'
        # to conform to standard java mutator naming convention. Remapping
        # allows explicit declaration of the java method that will be invoked
        # when the attribute is being set.

        # check if we hava to remap the attribute to a different mutator
        if(map_attribute_to_java_method_hash !=nil)
          remapped_attribute=map_attribute_to_java_method_hash[key.to_s]
        else
          remapped_attribute=nil
        end

        #if remap
        if(remapped_attribute !=nil)
          #puts "Remapped attribute [#{key}] to [#{remapped_attribute}]"
          # set the java mutator method name to the remapped value
          if(remapped_attribute.starts_with?('set'))
            java_method_name="#{remapped_attribute}"
            java_method_name[0]='g' # note this modifies the config value
            # TODO figure out why dup isnt working

          end
          
        else
          # puts "no remapping needed for [#{key}]"
          #the convention is to call the java set(attribute) mutator
          #convert the AR attribute to the java camelcase and prefix with set
          java_method_name="get"+camel_case(key.to_s)
        end

        Rails.logger.debug(">>Mutator Method Name: #{java_method_name}")
        # need to get the java value

        java_value = java_value_object.send(java_method_name)
        # test for any 'automatic-conversions' from by the RJB
        # get the class return type
        java_value_ruby_class=java_value.class
        Rails.logger.debug(">>java value (ruby class):[#{java_value_ruby_class}]")
        
        if(java_value ==nil)
          Rails.logger.debug("Do nothing for nil values")
        else
          # convert ruby 'primitives' to java primitives
          log_hr
          # handle the rjb automagic conversions
          # in these cases the 'java-value' has already been converted
          # to a ruby value
          if(java_value_ruby_class.to_s=='Fixnum')
            ruby_value=java_value
          elsif(java_value_ruby_class.to_s=='String')
            ruby_value=java_value

          elsif(java_value_ruby_class.to_s=='FalseClass')
            ruby_value=java_value

          elsif(java_value_ruby_class.to_s=='TrueClass')
            ruby_value=java_value


          else
            # not an automatic conversion type so handle
            # manually convert

            #get the class name of the value
            java_value_class_name = java_value.getClass().getName()

            Rails.logger.debug(">>java value class name: #{java_value_class_name}")

            # handle booleans
            if(java_value_class_name=="java.lang.Boolean")
              java_boolean_class=Rjb::import("java.lang.Boolean")
              if(java_value== java_boolean_class.TRUE)
                ruby_value = true;
              else
                ruby_value= false;
              end
              # handle Time & Date
            elsif(java_value_class_name== "java.util.Date")
              # converts a java Date object to a ruby date
              java_simple_date_formatter=Rjb::import("java.text.SimpleDateFormat").new("yyyy/MM/dd HH:mm:ss")
             
              formatted_date_string = java_simple_date_formatter.format(java_value)
              Rails.logger.debug("Formatted java date string: #{formatted_date_string}")
              ruby_value=Time.zone.parse(formatted_date_string) #("%Y/%m/%d %H:%M:%S")
              Rails.logger.debug("ruby time: #{ruby_value}")
            elsif(java_value_class_name== "java.util.HashMap")
              ruby_value=convert_java_hashmap_to_ruby(java_value)
            else
            
              ruby_value=nil
            end
            # set thh ruby value on the parent active record model
          end
          # get the target attribute type from the ActiveRecord model
          ar_target_attribute=parent.send(key.to_sym)
          if(ar_target_attribute==nil)
            ar_target_type="indeterminate"
          else
            ar_target_type=ar_target_attribute.class
          end
          Rails.logger.debug("ActiveRecord target type:#{ar_target_type}")
          Rails.logger.debug("pre mutator invocation:#{parent.to_json}")
          Rails.logger.debug("Converted Ruby Value: #{ruby_value}")
          ruby_attribute_mutator="#{key}="
          Rails.logger.debug("ruby_attribute_mutator: #{ruby_attribute_mutator}")
          parent.send(ruby_attribute_mutator.to_sym,ruby_value)
          Rails.logger.debug("self.attribute=:#{parent.send(key)}")
          Rails.logger.debug("post mutator invocation:#{parent.to_json}")
          log_hr
        end
      end

      # recursively call the associations
      ################################################
      # set any associations defined by the :include #
      ################################################

      if (include_array != nil)
        # loop over the include array to get the included association hashes
        include_array.each do |included_association|

          Rails.logger.debug("included association: #{included_association}")
          # get then name of the association attribute (the config)
          include_attribute_name=included_association[:attribute_name]

          # get the java type
          #get the vo accessor for the association
          included_vo_accessor=included_association[:java_method]
          if(included_vo_accessor == nil)
            #no explicit mutator was defined so use the default
            included_vo_accessor=create_java_accessor_name(include_attribute_name)
          else
            included_vo_accessor[0]='g' # change the mutator to an accessor
          end

          # call the association pointed to by the include_attribute_name 's accessor
          include_java_value_object = java_value_object.send(included_vo_accessor)
          include_ar_parent = create_default_active_record_model_from_java_value_object(include_java_value_object)
          # make the recursive call to create the sub-graph
          # included association represents the association configuration
          Rails.logger.debug("populate_active_record_model_from_java_value_object(#{include_ar_parent.class},#{include_java_value_object.getClass().getName()}, #{included_association})")


          populate_active_record_model_from_java_value_object(include_ar_parent,include_java_value_object, included_association)



          ar_method_name=include_attribute_name+'='

          #now set the subtree on the current level VO
          Rails.logger.debug("#{parent.class}.send(#{ar_method_name} , #{include_ar_parent.class})")


          


          parent.send(ar_method_name.to_sym,include_ar_parent)

        end
      end
      log_hr
      return parent
    end

    def convert_java_object_to_ruby(java_object)

    end


    def convert_java_hashmap_to_ruby(java_hashmap)
      # get the keys in the hashmap
      keys = java_hashmap.keySet()
      # create the receiving hash
      ruby_hash = Hash.new
      #iterate over the keys
      keys.each do |key|
        #retrieve the java_value
        java_value=java_hashmap.get(key)
        #convert the java value to ruby
        ruby_value = convert_java_object_to_ruby(java_value)
        ruby_hash[key.toString().to_sym]=ruby_value
      end
      return ruby_hash
    end


  end
end

ActiveRecord::Base.send(:include, ActsAsJavaValueObject)
