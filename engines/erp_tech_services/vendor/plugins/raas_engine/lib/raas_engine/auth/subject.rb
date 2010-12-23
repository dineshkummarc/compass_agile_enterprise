class RaasEngine::Auth::Subject
  PRINCIPAL_SET = 1
  PUB_CREDENTIAL_SET = 2
  PRIV_CREDENTIAL_SET = 3

  def initialize(read_only = false)
    @read_only = read_only
    @principals = RaasEngine::Auth::SecureSet.new(self, PRINCIPAL_SET)
    @pub_credentials = RaasEngine::Auth::SecureSet.new(self, PUB_CREDENTIAL_SET)
    @priv_credentials = RaasEngine::Auth::SecureSet.new(self, PRIV_CREDENTIAL_SET)
  end

  def is_read_only()
    return @read_only
  end

  def get_principals()
    return @principals
  end

  def get_pub_credentials()
    return @pub_credentials
  end

  def get_priv_credentials()
    return @priv_credentials
  end

  def get_principal_by_class(type)
    self.get_principals().type_equals(type)
  end

  def self.do_as_role(subject, role, exception, &block)
    roles = subject.get_principal_by_class("Role")
    if roles.include?(role)
      block.call
    else
      exception = RaasEngine::Exceptions::Auth::PrivilegedActionException.new("Action not allowed") if exception.nil?
      raise exception
    end
  end

  def self.check_permission(subject, permission, exception, &block)
    permissions = subject.get_pub_credentials()
    if permissions.contains?(permission)
      block.call
    else
      exception = RaasEngine::Exceptions::Auth::PrivilegedActionException.new("No Permissions to perform this action") if exception.nil?
      raise exception
    end
  end
end