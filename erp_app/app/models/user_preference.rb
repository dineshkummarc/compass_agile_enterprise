class UserPreference < ActiveRecord::Base
  belongs_to :user, :dependent => :destroy
  belongs_to :preference, :dependent => :destroy
  belongs_to :preferenced_record, :polymorphic => true, :dependent => :destroy
end
