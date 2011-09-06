class ValidPreferenceType < ActiveRecord::Base
  belongs_to :preference_type, :dependent => :destroy
  belongs_to :preferenced_record, :polymorphic => true, :dependent => :destroy
end
