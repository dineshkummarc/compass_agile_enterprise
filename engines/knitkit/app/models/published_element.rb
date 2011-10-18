class PublishedElement < ActiveRecord::Base
  belongs_to :published_website
  belongs_to :published_element_record, :polymorphic => true
  belongs_to :published_by, :class_name => "User"

  def published_by_username
    self.published_by.login rescue ''
  end
end