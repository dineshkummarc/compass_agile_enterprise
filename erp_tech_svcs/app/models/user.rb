class User < ActiveRecord::Base
  include ActiveModel::Validations

  attr_accessor :password_validator

  has_roles
  include ErpTechSvcs::Utils::CompassAccessNegotiator

  belongs_to :party

  attr_accessible :email, :password, :password_confirmation
  authenticates_with_sorcery!

  #password validations
  validates_confirmation_of :password, :message => "should match confirmation", :if => :password
  validates :password, :presence => true, :password_strength => true, :if => :password

  #email validations
  validates :email, :presence => {:message => 'Email cannot be blank'}
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/

  #username validations
  validates :username, :presence => {:message => 'Username cannot be blank'}
  validates_uniqueness_of :username

  #these two methods allow us to assign instance level attributes that are not persisted.  These are used for mailers
  def instance_attributes
    @instance_attrs.nil? ? {} : @instance_attrs
  end

  def add_instance_attribute(k,v)
    @instance_attrs = {} if @instance_attrs.nil?
    @instance_attrs[k] = v
  end

end
