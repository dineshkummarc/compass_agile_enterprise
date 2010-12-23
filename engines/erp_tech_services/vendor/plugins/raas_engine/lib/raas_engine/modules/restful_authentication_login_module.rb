class RaasEngine::Modules::RestfulAuthenticationLoginModule

  def initialize(subject, callbackHandler, sharedState = nil, control_flag = "REQUIRED", options = nil)
    @callbackHandler = callbackHandler
    @subject = subject
    @@sharedState = sharedState
    @control_flag = control_flag.upcase
    @options = options
    @tempPrincipals = []
    @tempCredentials = []
    @success = false
  end

  def control_flag
    @control_flag
  end

  def login()
    if(@callbackHandler.nil?)
      raise RaasEngine::Exceptions::Auth::LoginExceptionError.new("Error: no CallbackHandler available")
    end
    begin
      callbacks = {:username => "", :password => ""}
      @callbackHandler.handle(callbacks)

      username = callbacks[:username].strip()
      password = callbacks[:password].strip()

      @success = validate_credentials(username,password)
      raise RaasEngine::Exceptions::Auth::LoginExceptionError.new("Authentication Failed") unless @success == true
      return true
    rescue RaasEngine::Exceptions::Auth::LoginExceptionError => ex
      @success = false;
      raise ex
    rescue Exception => ex
      @success = false;
      raise RaasEngine::Exceptions::Auth::LoginExceptionError.new(ex.message)
    end
  end

  def commit()
    if(@success == true)
      if(@subject.is_read_only())
        raise RaasEngine::Exceptions::Auth::LoginExceptionError.new("Subject is Readonly")
      end

      begin
        @subject.get_principals().add_all(@tempPrincipals)
        @subject.get_pub_credentials().add_all(@tempCredentials)

        clear_temp_arrays()
        return true
      rescue Exception => e
        raise RaasEngine::Exceptions::Auth::LoginExceptionError.new(e.message)
      end
    else
      clear_temp_arrays()
      return true
    end
    return true
  end

  def logout()
    clear_temp_arrays()
    clear_subject()
    return true
  end

  def abort()
    @success = false
    clear_temp_arrays()
    logout()
    return true
  end

  private

  def clear_subject()
    @subject.get_principals().remove_all()
    @subject.get_pub_credentials().remove_all()
    @subject.get_priv_credentials().remove_all()
  end

  def clear_temp_arrays()
    @tempPrincipals.clear()
    @tempCredentials.clear()
  end

  def validate_credentials(username,password)
    u = SiteUser.find(:first, :conditions => ['login = ?',username])
    return false if u.nil? || !u.authenticated?(password)
    @tempPrincipals << u
    @tempPrincipals << u.roles
    @tempCredentials = AuthPermission.for_user(u)
    return true
  end

end