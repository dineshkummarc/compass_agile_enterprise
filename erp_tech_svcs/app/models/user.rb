require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  # Add identity_url if you want users to be able to update their OpenID identity
  attr_accessible :login, :email, :email_confirmation, :name, :first_name, :last_name, :password, :password_confirmation, :invitation_token, :activation_code, :activation_code_expires_at

  belongs_to :party
  attr_accessible :roles
  has_and_belongs_to_many :roles
  
  validates_presence_of     :login
  validates_length_of       :login,    :in => 3..40, :too_long => "too login", :too_short => "too short"

  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :in => 6..100, :too_long => "too long", :too_short => "too short"
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  #before_create :make_activation_code
  before_save :format_name  
  
  #Restful Auth
  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    activation_code.nil?
  end

  def activated?
    activation_code.nil?
  end

  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = self.find(:first, :conditions => ['login = ? and activated_at IS NOT NULL', login])
    u && u.authenticated?(password) ? u : nil
  end
  #EOF Restful Auth

  def permissions
    @ctx ||= AuthContext.new(self)
  end

  def client_preference(app)
    self.client_preferences.find(:first, :conditions => ["user_id = ? AND client_id = ?", self.id, app.id])
  end
  
	def self.member_list(page)
		paginate :all,
      :per_page => 50, :page => page,
      :conditions => ['enabled = ? and activated_at IS NOT NULL', true],
      :order => 'login'
	end

	def self.administrative_member_list(page)
		paginate :all,
      :per_page => 50, :page => page,
      :order => 'login'
	end

	def to_xml(options = {})
		#Add attributes accessible by xml
    #Ex. default_only = [:id, :login, :name]
		default_only = []
    options[:only] = (options[:only] || []) + default_only
    super(options)
  end

  def contains_role?(r)
    self.roles.each do |this_role|
      if(this_role.internal_identifier==r)
        return true
      end
    end
    return false
  end

  def contains_roles?(passed_roles)
    passed_roles.each do |passed_role|
      if contains_role?(passed_role)
        return true
      end
    end
    return false
  end

  def add_role(r)
    found = false
    self.roles.each do |role|
      if role.internal_identifier == r
        found = true
      end
    end
    self.roles << Role.find_by_internal_identifier(r) if found == false
  end

  def contains_permissions?(perm)
    found = false
    perms = perms.to_a unless perms.is_a?(Array)
    user_perms = AuthPermission.for_user(self).map(&:internal_identifier)
    perms.each do |perm|
      found = true if user_perms.include?(perm)
    end

    return found
  end

  def activation_link_expired?(code)
    activation_expiration_date = self.activation_code_expires_at
    current_date = Time.now
    if(current_date > activation_expiration_date)
      return true
    else
      return false
    end
  end

  # Password reset method, only available to SiteUsers
	# yield error, message, path, failure
	def self.find_and_reset_password(password, password_confirmation, reset_code, &block)
		u = find :first, :conditions => ['password_reset_code = ?', reset_code]
		case
		when (reset_code.blank? || u.nil?)
			yield :error, "Invalid password reset code, please check your email and try again.", "root_path", true
		when (password.blank? || (password != password_confirmation))
			yield :error, "Password and password confirmation did not match.", nil, false
		else
			u.password = password
			u.password_confirmation = password_confirmation
			if u.save
				u.reset_password!
				yield :notice, "Password reset.", "login_path", false
			else
				yield :error, "There was a problem resetting your password.", "root_path", false
			end
		end
	end

	# Password reset method, only available to SiteUsers
  def self.find_for_forget(email)
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
		return false if (email.blank? || u.nil? || (!u.identity_url.blank? && u.password.blank?))
		(u.forgot_password && u.save) ? true : false
  end

  protected

  def generate_password
    source_characters = "0124356789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    password = ""
    1.upto(10) { password += source_characters[rand(source_characters.length),1] }
    return password
  end

  private

  def format_name
    self.name = "#{self.first_name} #{self.last_name}"
  end
end
