class ConfigurationOption < ActiveRecord::Base
  has_and_belongs_to_many :configuration_item_types
  has_and_belongs_to_many :configuration_items

  validates :value, :presence => {:message => 'Value can not be blank.'}

  def to_js_hash
    {
      :id => self.id,
      :value => self.value,
      :description => self.description,
      :internalIdentifier => self.internal_identifier,
      :comment => self.comment,
      :createdAt => self.created_at,
      :updatedAt => self.updated_at
    }
  end
end
