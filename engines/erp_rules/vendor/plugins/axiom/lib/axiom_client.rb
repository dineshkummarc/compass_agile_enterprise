require 'rjb'

# AxiomClient provides a Ruby wrapper around the AXIOM Server RMI client

class AxiomClient

  # default to loopback and standard rmi registry port
  def initialize(host='127.0.0.1',port=1099)
    @host=host
    @port=port
  end
  def get_client
    if(@client==nil)
      axiom_class=Rjb::import('com.tnsolutionsinc.axiom.client.AxiomClient')
      Rails.logger.debug("creating client to #{@host}:#{@port}")
      @client=axiom_class.new(@host,@port)
      Rails.logger.debug("created AxiomClient: #{@client}")
    end
    return @client
  end

  # provides a method to remotely shutdown the server
  def shutdown
        
    get_client.shutdownServer()

  end

  # here is where we do the heavy lifting
  # invoke takes a ruby ruleset and executionContext
  # and converts it into a java ruleset and execution context
  # invokes the remote rule engine
  # then converts the java results into a ruby result
  def invoke(ruleset,execution_context)
    Rails.logger.debug("------------------------------------------------------")
    Rails.logger.debug("Ruleset: #{ruleset}")
    Rails.logger.debug("ExecutionContext: #{execution_context}")
    # create the java parameters
    java_ruleset=Rjb::import("java.util.ArrayList").new
     

    #populate the rules to be used
    ruleset.each do |rule|
      java_ruleset.add(rule)
    end

    Rails.logger.debug("-----------------------------------------------------------------------------------------------------------------------------------")
    Rails.logger.debug("Customer    CTX:#{execution_context[:customer]}")
    Rails.logger.debug("Environment CTX:#{execution_context[:environment]}")
    Rails.logger.debug("Search      CTX:#{execution_context[:search]}")
    Rails.logger.debug("-----------------------------------------------------------------------------------------------------------------------------------")

    java_execution_context =execution_context_to_java(execution_context)

    

    ##########################################################
    ## if the environment :test_client == true
    ## execute the test rule
    #########################################################
    #    if(execution_context[:environment_context][:test_client]==true)
    #      Rails.logger.debug("Adding test call")
    #      message=Rjb::import('com.tnsolutionsinc.compass.model.Message')
    #      message_instance=message.new
    #      message_instance.setStatus(message.HELLO)
    #      message_instance.setMessage("incoming")
    #
    #      #add the rule
    #      java_ruleset.add("Hello")
    #      # add the Message type to the context
    #      java_execution_context.put("message",message_instance)
    #
    #
    #      #################
    #      #end of test code
    #      #################
    #    end
    # convert from ruby to java
    # TODO....
    #
    # invoke the axiom rule engine
    java_results= java_invoke(java_ruleset,java_execution_context)
    Rails.logger.info("Axiom java result #{java_results.toString()}")
    # create a ruby result
    ruby_result=convert_java_result_map_to_ruby(java_results)


    return ruby_result

  end

  # converts the ruby execution context to a java execution context
  def execution_context_to_java(execution_context)
    
    Rails.logger.debug("------------------------------------------------------")
    Rails.logger.debug("execution_context:#{execution_context}")
    execution_context.each_pair do |key,value|
      Rails.logger.debug("execution_context key[#{key}]=#{value}")
    end
    if (execution_context ==nil)
      raise "ExecutionContext must not be NIL"
    end

    # make sure the execution context is an instance of or a
    # subclass of Hash
    if(execution_context.instance_of? Hash)

      Rails.logger.debug("Create Execution Context:#{execution_context}")
      # create the execution context
      java_execution_ctx=Rjb::import("com.tnsolutionsinc.axiom.context.ExecutionContext").new
          
      # populate the execution context
      Rails.logger.debug("Set Environment Context")
      java_execution_ctx.put("ENVIRONMENT_CONTEXT",environment_context_to_java(execution_context[:environment]))
      Rails.logger.debug("Set Customer Context")
      java_execution_ctx.put("CUSTOMER_CONTEXT",customer_context_to_java(execution_context[:customer]))
      Rails.logger.debug("Set Search Context")
      java_execution_ctx.put("SEARCH_CONTEXT",search_context_to_java(execution_context[:search]))

      # handle directives
      # supported directives :
      # (1) suppress_execution_context_return
      if(execution_context[:directives] !=nil)
        if(execution_context[:directives].instance_of? Hash )
          directives=execution_context[:directives]
          java_directives_map=Rjb::import("java.util.HashMap").new
          if(directives[:suppress_execution_context_return]==true)
            java_directives_map.put("suppress_execution_context_return",true);
          end

          java_execution_ctx.put("DIRECTIVES",java_directives_map);
        end

      end

      
      return java_execution_ctx
    else
      raise "ExecutionContext must be a Hash or subclass of Hash"
    end
  end

  #  def convert_to_java_hashmap(hash_instance)
  #    Rails.logger.debug("convert_to_java_hashmap:#{hash_instance.to_yaml}")
  #    hashmap = Rjb::import('java.util.HashMap').new
  #    # loop over the hash to populate the java instance
  #    hash_instance.each_pair do |key,value|
  #      if(value.is_a? String)
  #        hashmap.put(key,value)
  #      end
  #    end
  #    return hashmap
  #  end

  def convert_java_result_map_to_ruby(java_result_map)
    # note we are converting from a java object
    # so the source methods will look a bit strange
    ruby_result=Hash.new
    # convert the rule execution list into an array of java strings
    rules_fired_java = java_result_map.getRuleExecutionList.toArray
    rules_fired = Array.new
    # loop over the array to build the ruby version
    rules_fired_java.each do |rule_fired|
      rules_fired << rule_fired.toString
    end
    # add the ruby rule exection list to the result map
    ruby_result[:rule_execution_list]=rules_fired
    # get all the hash keys for this result map
    key_set=java_result_map.keySet()
    Rails.logger.debug("key_set:#{key_set.toString()}")
    if(key_set!=nil)
      keys=key_set.toArray()
      keys.each do| key|
        value = java_result_map.get(key)
        Rails.logger.debug("result map key:#{key.toString()} - #{value.toString()}")
        if(key.toString()=="EXECUTION_CONTEXT")
          ruby_result[key.toString.to_sym]=convert_java_execution_context_to_ruby(value)
        else
          ruby_result[key.toString.to_sym]=convert_java_object_to_ruby(value)
        end
      end
    end


    return ruby_result
    
  end

  def convert_java_object_to_ruby(java_value)
    java_value_ruby_class=java_value.class
    Rails.logger.debug(">>java value (ruby class):[#{java_value_ruby_class}]")
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
      elsif(java_value_class_name== "java.lang.Long")
        ruby_value=java_value.longValue
      elsif(java_value_class_name== "java.lang.Integer")
        ruby_value=java_value.intValue
        # handle Time & Date
      elsif(java_value_class_name== "java.util.Date")
        # converts a java Date object to a ruby date

        ruby_value=Date.parse(java_value.toString)
        Rails.logger.debug("ruby time: #{ruby_value}")
      elsif(java_value_class_name== "java.util.HashMap")
        ruby_value=convert_java_hash_map_to_ruby_hash("unknown",java_value)
      elsif(java_value_class_name== "java.util.ArrayList")
        ruby_value=convert_java_arraylist_to_ruby(java_value)
      else

        ruby_value=nil
      end
      # set thh ruby value on the parent active record model
    end
    return ruby_value
  end

  def convert_java_arraylist_to_ruby(java_value)
    ruby_array = Array.new
    java_array=java_value.toArray()
    java_array.each do |java_array_element|
      ruby_array<< convert_java_object_to_ruby(java_array_element)
    end


    return ruby_array
  end

  def convert_java_execution_context_to_ruby(java_execution_context)
    Rails.logger.debug("convert java execution context to ruby")
    execution_context = Hash.new


    # note we are converting from a java object
    # so the source methods will look a bit strange
    ruby_result=Hash.new
    # get all the hash keys for this result map
    key_set=java_execution_context.keySet()
    Rails.logger.debug("key_set:#{key_set.toString()}")
    if(key_set!=nil)
      keys=key_set.toArray()
      keys.each do| key|
        value = java_execution_context.get(key)
        Rails.logger.debug("execution ctx key:#{key.toString()} - #{value.toString()}")
        if(key.toString()=="ENVIRONMENT_CONTEXT")
          ruby_result[key.toString]=convert_java_environment_context_to_ruby(value)
        elsif (key.toString()=="CUSTOMER_CONTEXT")
          ruby_result[key.toString]=convert_java_customer_context_to_ruby(value)
        elsif (key.toString()=="SEARCH_CONTEXT")
          ruby_result[key.toString]=convert_java_search_context_to_ruby(value)
        else
          ruby_result[key.toString]=value.toString
        end
      end
    end

    return ruby_result
    ## return execution_context
  end

  def convert_java_environment_context_to_ruby(ctx)
    Rails.logger.debug("Convert java environment context to ruby")
     
    return convert_java_hash_map_to_ruby_hash("environment_context",ctx)
  end

  def convert_java_customer_context_to_ruby(ctx)
    Rails.logger.debug("Convert java customer context to ruby")
    return convert_java_hash_map_to_ruby_hash("customer_context",ctx)
  end

  def convert_java_search_context_to_ruby(ctx)
    Rails.logger.debug("Convert java search context to ruby")
    return convert_java_hash_map_to_ruby_hash("search_context",ctx)

  end

  # provide a general method for converting java hash_map to ruby hash
  def convert_java_hash_map_to_ruby_hash(map_name,java_hash_map)
    ruby_hash=Hash.new
    # get all the hash keys for this result map
    key_set=java_hash_map.keySet()
    Rails.logger.debug("key_set:#{key_set.toString()}")
    if(key_set!=nil)
      keys=key_set.toArray()
      keys.each do| key|
         
        value = java_hash_map.get(key)
        Rails.logger.debug("#{map_name} key:#{key.toString()} - #{value.toString()}")
        if(is_active_record_model(value))
          ruby_hash[key.toString.to_sym]=convert_java_value_object_to_active_record_model(value)
        else
          ruby_hash[key.toString.to_sym]=convert_java_object_to_ruby(value)
        end
      end
    end


    return ruby_hash
  end

  # should probably replace with java reflection
  def is_active_record_model(java_obj)
    begin
      name=java_obj.getARModelName
      Rails.logger.debug("AR model:"+name)
      return true
    rescue
    end
    return false
  end

  # take a java value object model and convert it into the
  # corresponding ActiveRecord model by performing a lookup
  # by id

  def convert_java_value_object_to_active_record_model(java_value_object)
    ## get an initial ar model to work with
    ar_model_name=java_value_object.getARModelName()
    ar_model_id=java_value_object.getId()

    Rails.logger.debug "convert java vo to ar model"
    Rails.logger.debug "ar model name    :#{ar_model_name}"
    Rails.logger.debug "ar model id      :#{ar_model_id}"
    ar_model_class = Kernel.const_get(ar_model_name)
    Rails.logger.debug "ar model class   :#{ar_model_class}"
    ar_model_instance=ar_model_class.find(ar_model_id)
    Rails.logger.debug "ar model instance   :#{ar_model_instance}"
    # call update against this ar model
    ar_model_instance.update_model_from_java_value_object(java_value_object)
  end

   
  #converts the ruby environment_context into a java environment context
  def environment_context_to_java(environment_ctx)
    java_environment_ctx=Rjb::import("com.tnsolutionsinc.axiom.context.EnvironmentContext").new
    # convert context values into java objects
    if(environment_ctx != nil)
      Rails.logger.debug("Populate Environment Context")
      java_environment_ctx=populate_java_context_with_ruby_context(java_environment_ctx,environment_ctx)
    end
    return java_environment_ctx

  end

  # convert a customer context into a java customerContext
  def customer_context_to_java(customer_ctx)
    java_customer_ctx=Rjb::import("com.tnsolutionsinc.axiom.context.CustomerContext").new

    # convert context values into java objects
    if(customer_ctx != nil)
      Rails.logger.debug("Populate Customer Context")
      java_customer_ctx=populate_java_context_with_ruby_context(java_customer_ctx,customer_ctx)
  
    end
    Rails.logger.debug("java_customer_ctx:#{java_customer_ctx.toString}")
    return java_customer_ctx

  end

  # convert a search context into a java searchContext
  def search_context_to_java(search_ctx)
    java_search_ctx=Rjb::import("com.tnsolutionsinc.axiom.context.SearchContext").new

    # convert context values into java objects
    if(search_ctx != nil)
      Rails.logger.debug("Populate SearchContext")
      java_search_ctx=populate_java_context_with_ruby_context(java_search_ctx,search_ctx)

    end
    Rails.logger.debug("java_search_ctx:#{java_search_ctx.toString}")
    return java_search_ctx

  end

  # populate java context with ruby context elements
  def populate_java_context_with_ruby_context(java_ctx,ruby_ctx)
    ruby_ctx.each_pair do |key , value|

      Rails.logger.debug("ruby_context key:#{key},value#{value}")
      if(value.is_a? ActiveRecord::Base)
        # test if the AR model can be converted to java
        if(value.respond_to? :to_java)
          java_value=value.to_java
          Rails.logger.debug("ActiveRecord: #{key},value#{java_value} - added to java_customer_ctx")

        else
          Rails.logger.debug("ActiveRecord:#{key},value#{value} - can NOT be converted to java instance")
        end
        
      else
        Rails.logger.warn("Prepare to convert [pair (#{key},#{value}] to java")
        java_value=convert_ruby_to_java(value)
        
        
      end
      Rails.logger.debug("Converted key:[#{key.to_s}]/value:[#{value}]->[#{java_value}]")
      if(java_value!=nil)
        java_ctx.put(key.to_s,java_value)
      end
    end
     
    Rails.logger.debug("java_ctx #{java_ctx.toString()}")
    Rails.logger.debug("java_ctx keys:#{java_ctx.keySet().toString()}")
    iterator=java_ctx.keySet().iterator()
    while(iterator.hasNext())
      new_key=iterator.next()
      Rails.logger.debug("context map key [#{new_key.toString()}]:value[#{java_ctx.get(new_key).toString()}]")

    end
    return java_ctx
  end

  # this method will attempt to convert a ruby object to a corresponding java object
  # NOTE: DO NOT USE THIS FOR ACTIVE RECORD MODELS
  #       ActiveRecord models will raise an exception (by design)
  def convert_ruby_to_java(ruby_value)
    Rails.logger.debug("convert_ruby_to_java-ruby_value:#{ruby_value}-class:#{ruby_value.class}")
    if (ruby_value ==nil)
      return nil
    end
    if(ruby_value.is_a? ActiveRecord::Base)
      raise "method cannot be used for converting ActiveRecord models"
    end
    if(ruby_value.instance_of? Hash)
      return convert_to_java_hashmap(ruby_value)
    elsif(ruby_value.instance_of? HashWithIndifferentAccess)
      return convert_to_java_hashmap(ruby_value)
    elsif (ruby_value.instance_of?  Array)
      return convert_to_java_array(ruby_value)
    elsif (ruby_value.instance_of?  Date)
      return convert_to_java_date(ruby_value)
    elsif (ruby_value.instance_of?  Time)
      return convert_to_java_date(ruby_value)
    elsif(ruby_value.instance_of? Collections::NamedHash)
      return convert_to_java_named_map(ruby_value)
    elsif(ruby_value.instance_of? ActiveSupport::TimeWithZone)
      return convert_to_java_date(ruby_value)
    elsif (ruby_value.instance_of?  Collections::NamedArray)
      return convert_to_java_named_array(ruby_value)
    else
      # let the bridge determine the appropriate conversion mapping
      Rails.logger.debug("RJB conversion for:#{ruby_value}")
      #return ruby_value and let the bridge attempt the conversion
      return ruby_value
    end
  end

  def convert_to_java_date(value)
    ruby_date = value.to_date
    Rails.logger.debug("Convert #{hash} to java.util.Date")
    java_date=Rjb::import("java.util.Date").new(ruby_date.year-1900, ruby_date.month-1, ruby_date.day, 0,0)
    
    if(value.instance_of? Time)
      
    elsif(value.instance_of? Date)
      
    end
    return java_date
  end
  # This method will convert a ruby hash into a java.util.HashMap
  def convert_to_java_hashmap(hash)
    Rails.logger.debug("Convert #{hash} to java.util.HashMap")
    java_hashmap=Rjb::import("java.util.HashMap").new

    hash.each_pair do |key , value|
      java_value=convert_ruby_to_java(value)
      Rails.logger.debug("key:#{key},value:#{java_value}")
      java_hashmap.put(key.to_s,java_value)
    end
    return java_hashmap
  end

  # This method will convert a ruby NamedHash into a java NamedMap
  def convert_to_java_named_map(named_hash)
    Rails.logger.debug("Convert #{named_hash} to named_hash")
    java_named_map=Rjb::import("com.tnsolutionsinc.axiom.collections.NamedMap").new
    java_named_map.name=named_hash.name
    named_hash.each_pair do |key , value|
      java_value=convert_ruby_to_java(value)
      Rails.logger.debug("key:#{key},value:#{java_value}")
      java_named_map.put(key.to_s,java_value)
    end
    return java_named_map
  end


  #this method will convert a ruby NamedArray into a java NamedArray
  def convert_to_java_array(array)
    Rails.logger.debug("Convert #{array} to java.util.ArrayList")
    java_array=Rjb::import("java.util.ArrayList").new
    
    array.each do | value|
      java_value=convert_ruby_to_java(value)
      Rails.logger.debug("value:#{java_value}")
      java_array.add(java_value)
    end
    return java_array
  end

  #this method will convert a ruby NamedArray into a java NamedArray
  def convert_to_java_named_array(named_array)
    Rails.logger.debug("Convert #{named_array} to named_array")
    java_named_array=Rjb::import("com.tnsolutionsinc.axiom.collections.NamedArray").new
    java_named_array.name=named_array.name
    named_array.each do | value|
      java_value=convert_ruby_to_java(value)
      Rails.logger.debug("value:#{java_value}")
      java_named_array.add(java_value)
    end
    return java_named_array
  end
  

  #
  def java_invoke(java_ruleset,java_execution_context)
    java_results= get_client.invoke(java_ruleset,java_execution_context)
  end

  # for dev purposes only- remove
  # invokes the client test with set to Home Access
  def test_ha
    test("Home Access")
  end
  # for dev purposes only- remove 
  # invokes the client test with set to Home Access
  def test_ra
    test("Resort Access") 
  end

  #client test driver
  def test(type)
    
    ruleset=Array.new
    ruleset<<"ReservationSearch"
    execution_context=Hash.new

    environment_context=Hash.new
    customer_context=Hash.new
    search_context=Hash.new
    # get the first instance of timeshare pts ownership and
    #add it to the customer context
    ownership=TimesharePtsOwnership.first
    customer_context[:ownership]=ownership
    #set the search type to Home access
    search_context[:search_type]=type
    # add the test_client flag
    # environment_context[:test_client]=true
    execution_context[:environment_context]=environment_context
    execution_context[:customer_context]   =customer_context
    execution_context[:search_context]     =search_context

    invoke(ruleset,execution_context)
  end
end

 
