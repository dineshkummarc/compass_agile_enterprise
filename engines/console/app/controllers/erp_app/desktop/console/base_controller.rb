class ErpApp::Desktop::Console::BaseController < ErpApp::Desktop::BaseController
  def command
    logger.debug("command received:#{params}")
    begin
      result=""
      
      # NOTE- the console uses a shared binding. this is due to the fact
      # that binding instances are not serializable and cant be stored
      # in a user session. Until this is resolved we use a global var.
      # this should not pose a problem as the console should only be used
      # in development or by a sysadmin. 
      
      # the shared binding is needed to allow for variable scope visibility
      # across multiple requests 
      if($session_binding==nil)
        $session_binding=binding
      end
      
      command_message=params[:command_message]
      logger.debug("console session context:#{$session_binding}")
      logger.debug("command:#{command_message}")
      
      # here we handle any desktop console-specific command
      # these can include non-eval related funtions
      # or provide shortcuts to common eval expressions
      if(command_message.match(/^-help/))
        result = help_message
      elsif(command_message.match(/^-clear/))
        # this is actually handled in the console desktop application
        #result = evaluate_command("")
      elsif(command_message.match(/^-time/))
        result = evaluate_command("Time.now")
      elsif(command_message.match(/^-whoami/))
        result = evaluate_command("current_user.login")
      else
        result=evaluate_command(command_message)         
      end
      
      logger.debug("result#{result}")
      
      result_message =result.to_s.gsub("\n", "<br />\n")
      render :json=> {:success=>"#{result_message}<hr><br>"}
    end
  end
  private
  #****************************************************************************
  def help_message()
    message = "<font color='lightgray'><b>Compass Desktop Console Help<b><hr>"
    message<< "<ul>"
    message<< "<li>-clear : <font color='yellow'>Clear screen contents.</font></li>"
    message<< "<li>-help : <font color='yellow'>This help list.</font></li>"
    message<< "<li>-time : <font color='yellow'>Current time.</font></li>"
    message<< "<li>-whoami : <font color='yellow'>Logged in as.</font></li>"
    message<< "</ul> </font>"
  end
  #****************************************************************************
  def highlight(model)
    buffer=""
    model.attributes.keys.sort.each do |model_attribute_key|
      CompassLogger.debug("key:#{model_attribute_key}")
     
      buffer<<"<font color='yellow'>#{model_attribute_key}</font> <font color='lightgray'>=</font><font color='gold'>#{model.attributes[model_attribute_key]}</font> <font color='lightgray'>, </font>"
    end
    return buffer
  end
  #****************************************************************************
 
  def evaluate_command(command_message)
    CompassLogger.debug("evaluate_command(#{command_message}")
    begin
           
      result_eval = $session_binding.eval( command_message)
           
      if(result_eval.is_a? ActiveRecord::Base)
        result= render_active_record_model(result_eval)
      elsif (result_eval.is_a? Array)
        result= render_array(result_eval)
      elsif (result_eval.is_a? Hash)
        result= render_hash(result_eval)
      else
        #result="#{result_eval.class.to_s} #{result_eval.to_s}<br>"
        result="#{result_eval.to_s}<br>"
      end
        
    rescue Exception => e
      result = "<font color='red'>#{e.to_s}</font>"
    end
        
    return result
  end
  #****************************************************************************
  def render_active_record_model(result_eval)
    CompassLogger.debug("render_active_record_model:#{result_eval}")
    "<font color='YellowGreen'>#{result_eval.class} </font><br>#{highlight(result_eval)} "
  end
  #****************************************************************************
  def render_array(result_eval)
    result="#{result_eval.class.to_s}<br>"
    CompassLogger.debug("render_array:#{result_eval}")
    count=0
    result_eval.each do |array_element|
      if(array_element.is_a? ActiveRecord::Base)
        result<< "<font color='YellowGreen'>#{array_element.class}<font color='yellow'>[</font><font color='white'>#{count}</font><font color='yellow'>]</font> </font>#{highlight(array_element)} <br><br>"
      else
        result<<"<font color='YellowGreen'>#{array_element.class}<font color='yellow'>[</font><font color='white'>#{count}</font><font color='yellow'>]</font> </font>#{array_element} <br><br>"
      end
      count=count+1
    end
    return result
  end
  #****************************************************************************
  def render_hash(result_eval)
    CompassLogger.debug("render_hash:#{result_eval}")
    result="#{result_eval.class.to_s}<br>"
    count=0
    result_eval.keys.each do |hash_key|
      symbol_modifier=''
      if(hash_key.is_a? Symbol)
        symbol_modifier=':'
      end
      if(hash_key.is_a? ActiveRecord::Base)
        
        result<< "<font color='YellowGreen'>#{result_eval.class}<font color='yellow'>[</font><font color='white'>#{symbol_modifier}#{hash_key}</font><font color='yellow'>] => </font> </font>#{highlight(result_eval[hash_key])} <br>"
      else
        result<<"<font color='YellowGreen'>#{result_eval.class}<font color='yellow'>[</font><font color='white'>#{symbol_modifier}#{hash_key}</font><font color='yellow'>] => </font> </font>#{result_eval[hash_key]} <br>"
      end
      count=count+1
    end
    return result
  end
end