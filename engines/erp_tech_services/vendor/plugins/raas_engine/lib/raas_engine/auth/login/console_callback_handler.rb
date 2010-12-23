class RaasEngine::Auth::Login::ConsoleCallbackHandler
  def handle(callbacks)
    puts "Enter Username"
    callbacks[:username] = gets

    puts "Enter password"
    callbacks[:password] = gets
  end
end