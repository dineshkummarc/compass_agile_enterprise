class Widget < ActiveRecord::Base
  has_roles
  has_capabilities

  has_and_belongs_to_many :applications
  has_many :user_preferences, :as => :preferenced_record

  validates_uniqueness_of :xtype
  validates_uniqueness_of :internal_identifier

  def to_access_hash
    {
      :xtype => self.xtype,
      :roles => self.roles.collect{|role| role.internal_identifier},
      :capabilities => self.capabilites_to_hash
    }
  end
end
