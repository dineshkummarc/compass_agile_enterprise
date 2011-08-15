class Widget < ActiveRecord::Base
  has_and_belongs_to_many :applications
  has_and_belongs_to_many :roles
  has_many :user_preferences, :as => :preferenced_record
end
