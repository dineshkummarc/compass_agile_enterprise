class PublishedElement < ActiveRecord::Base
  belongs_to :published_website
  belongs_to :published_element_record, :polymorphic => true
end