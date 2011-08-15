class ValidPreferenceType < ActiveRecord::Base
  belongs_to :preference_type
  belongs_to :preferenced_record, :polymorphic => true
end
