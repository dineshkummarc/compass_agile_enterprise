class RaasEngine::Auth::Login::UsernamePasswordCallbackHandler
  def initialize(username, password)
    @username = username
    @password = password
  end

  def handle(callbacks)
    callbacks[:username] = @username
    callbacks[:password] = @password
  end
end