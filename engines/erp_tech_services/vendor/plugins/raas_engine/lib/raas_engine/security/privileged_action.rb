class RaasEngine::Security::PrivilegedAction
  class << self
    def run(excep=nil, &blck)
      unless block_given?
        raise RaasEngine::Security::PrivilegedExceptionActionException.new("Action not given.")
      else
        begin
          blck.call
        rescue Exception => ex
          excep = ex if excep.nil?
          raise excep
        end
      end
    end
  end
end