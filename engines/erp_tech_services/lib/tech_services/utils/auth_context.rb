# To change this template, choose Tools | Templates
# and open the template in the editor.

class AuthContext
  #for testing
  #attr_accessor :permissions

  def initialize(user)
    @user_id = user.id
    @permissions = AuthPermission.for_user(user).map(&:internal_identifier)
  end

  def add_role_by_name(role_name)
    @permissions += AuthPermission.for_role_name(role_name).map(&:internal_identifier) if ! role_name.nil?
  end

  def reload
    @permissions = nil
    @permissions = AuthPermission.for_user(User.find(@user_id)).map(&:internal_identifier)
  end

  def has_permission?(perm)
    @permissions.include? perm
  end

  def has_permissions?(perms)
    (perms - @permissions).blank?
  end
end
