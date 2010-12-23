module RaasEngine
  
end

=begin
ch = RaasEngine::Auth::Login::UsernamePasswordCallbackHandler.new("admin","password1")
lc = RaasEngine::LoginContext.new("orange_lake", RaasEngine::Auth::Subject.new(), ch)
begin
  lc.login()
rescue RaasEngine::Exceptions::Auth::LoginExceptionError => lee
  puts lee.message()
end

ch = RaasEngine::Auth::Login::ConsoleCallbackHandler.new()
lc = RaasEngine::LoginContext.new("orange_lake", RaasEngine::Auth::Subject.new(), ch)
begin
  lc.login()
rescue RaasEngine::Exceptions::Auth::LoginExceptionError => lee
  puts lee.message()
end


subject = lc.get_subject()

RaasEngine::Auth::Subject.do_as_role(subject, Role.find_by_internal_identifier("Admins"), nil) {
  (1..10).each do |i|
  puts i
  end
}

RaasEngine::Auth::Subject.do_as_role(subject, Role.find_by_internal_identifier("Admin"), nil) {
  (1..10).each do |i|
  puts i
  end
}

RaasEngine::Auth::Subject.check_permission(subject, AuthPermission.find_by_internal_identifier("hold_units"), nil) {
  (1..10).each do |i|
  puts i
  end
}

RaasEngine::Auth::Subject.check_permission(subject, AuthPermission.find_by_internal_identifier("hold_unit"), nil) {
  (1..10).each do |i|
  puts i
  end
}


=end