class RaasEngine::Security::AccessController
  class << self
    def do_privileged()
      yield
    end
  end
end