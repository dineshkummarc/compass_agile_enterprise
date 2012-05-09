class ValidDocument < ActiveRecord::Base
  belongs_to :documented_model, :polymorphic => true
  belongs_to :document, :dependent => :destroy
end
