class CategoryClassification < ActiveRecord::Base
  belongs_to :classification, :polymorphic => true
  belongs_to :category
end
