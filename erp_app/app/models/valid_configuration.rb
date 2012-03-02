class ValidConfiguration < ActiveRecord::Base
  belongs_to :configured_item, :polymorphic => true
  belongs_to :configuration, :dependent => :destroy
end
