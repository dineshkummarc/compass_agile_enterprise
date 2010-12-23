class RaasEngine::LoginContext
  INIT_METHOD     = "initialize"
  LOGIN_METHOD		= "login"
  COMMIT_METHOD		= "commit"
  ABORT_METHOD		= "abort"
  LOGOUT_METHOD		= "logout"
  OTHER           = "other"
  DEFAULT_HANDLER = "RaasEngine::Auth::Login::DefaultCallbackHandler"
  
  def initialize(name = nil, subject = nil, callbackHandler = nil, config = nil)
    @subject = subject
    @subjectProvided = ((subject.nil?) ? false : true)
    @loginSucceeded = false
    @configProvided = ((config.nil?) ? false : true)
    @config = config
    @creatorAcc = nil
    @moduleStack = []

    if name.blank?
      raise RaasEngine::Exceptions::Auth::LoginExceptionError.new("Invalid null input: name")
    end

    if (callbackHandler.nil?)
      @callbackHandler = load_default_callback_handler()
    else
      @callbackHandler = callbackHandler
    end
    
    @state = Hash.new()
    @PARAMS = Hash.new()
    @moduleIndex = 0
    @firstError = nil
    @firstRequiredError = nil
    @success = false
    init(name)
    clear_state()
  end

  def init(name)
    if name.blank?
      raise RaasEngine::Exceptions::Auth::LoginExceptionError.new("Invalid null input: name")
    end
    
    if(@config.nil?)
      @config = RaasEngine::Security::AccessController.do_privileged() {
        RaasEngine::Security::PrivilegedAction.run() {
          Constants::LOGIN_MODULES[name.to_sym]
        }
	    }
    end

    if(@config.nil?)
      raise RaasEngine::Exceptions::Auth::LoginExceptionError.new("No configuration for name")
    end

    @config.each do |stack|
      @moduleStack << stack[:module_name].constantize.new(@subject, @callbackHandler, @state, stack[:control_flag], stack[:options])
    end

  end

  def login()
    @loginSucceeded = false
    @subject = RaasEngine::Auth::Subject.new()if @subject.nil?

    begin
      begin
        invoke_priv(LOGIN_METHOD)
      rescue Exception => ex
        raise ex
      end
      
      invoke_priv(COMMIT_METHOD)
      @loginSucceeded = true
    rescue RaasEngine::Exceptions::Auth::LoginExceptionError => le
      begin
        invoke_priv(ABORT_METHOD)
      rescue
        raise le
      end
      raise le
    rescue Exception => le
      raise le
    end
  end

  def logout()
    raise RaasEngine::Exceptions::Auth::LoginExceptionError.new("nil subject - logout called before login") if @subject.nil?
    invoke_priv(LOGOUT_METHOD)
  end

  def get_subject()
    if (!@loginSucceeded && !@subjectProvided)
      return nil
    end
    return @subject
  end

  private

  def load_default_callback_handler()
    DEFAULT_HANDLER.constantize.new
  end

  def clear_state()
    @moduleIndex = 0
    @firstError = nil
    @firstRequiredError = nil
    @success = false
  end

  def throw_exception(originalError, le)
    clear_state()
    error = ((originalError.nil?) ? le : originalError)
    raise(error)
  end

  def invoke_priv(method_name)
    begin
      RaasEngine::Security::AccessController.do_privileged() {
        RaasEngine::Security::PrivilegedExceptionAction.run(RaasEngine::Exceptions::Auth::PrivilegedActionException.new("action not allowed")) {
          invoke(method_name)
          nil
        }
	    }
    rescue RaasEngine::Exceptions::Auth::PrivilegedActionException => pae
	    raise RaasEngine::Exceptions::Auth::LoginExceptionError.new(pae.message())
    end
  end

  def invoke(method_name)
    @moduleStack.each do |stack|
      begin
        stack.send(method_name)
        @success = true
      rescue RaasEngine::Exceptions::Auth::LoginExceptionError => lee
        if stack.control_flag == "REQUIRED"
          @firstRequiredError = lee if @firstRequiredError.nil?
          break
        else
          @firstError = lee if @firstError.nil?
        end
        
        @success = false
      end
    end

    if(!@firstRequiredError.nil?)
      throw_exception(@firstRequiredError, nil)
    elsif(!@success && !@firstError.nil?)
      throw_exception(@firstError, nil)
    elsif(!@success)
      throw_exception(RaasEngine::Exceptions::Auth::LoginExceptionError.new("Login Failure in all modules"), nil)
    else
      clear_state();
    end
  end
end