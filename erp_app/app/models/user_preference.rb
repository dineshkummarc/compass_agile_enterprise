class UserPreference < ActiveRecord::Base
  belongs_to :user
  belongs_to :preference
  belongs_to :preferenced_record, :polymorphic => true
end
