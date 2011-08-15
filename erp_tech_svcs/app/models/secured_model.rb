class SecuredModel < ActiveRecord::Base
  belongs_to :secured_record, :polymorphic => true
  has_and_belongs_to_many :roles
end
