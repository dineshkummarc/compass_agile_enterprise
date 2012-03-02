class CapableModel < ActiveRecord::Base
  belongs_to :capable_model_record, :polymorphic => true
  has_and_belongs_to_many :capabilities
end
