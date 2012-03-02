class Configuration < ActiveRecord::Base
  has_many :configuration_items, :dependent => :destroy do
    def by_category(category)
      includes({:configuration_item_type => [:category_classifications]}).where(:category_classifications => {:category_id => category})
    end
  end
  has_and_belongs_to_many :configuration_item_types do
    def by_category(category)
      includes(:category_classifications).where(:category_classifications => {:category_id => category})
    end
  end
  
  alias :items :configuration_items
  alias :item_types :configuration_item_types

  def update_configuration_item(configuration_item_type, internal_identifiers)
    item = self.items.where('configuration_item_type_id = ?', configuration_item_type.id).first
    raise "Configuration item does not exist for configuration #{self.description}" if item.nil?

    item.clear_options
    item.set_options(internal_identifiers)
  end

  alias :update_item :update_configuration_item

  def get_configuration_item(configuration_item_type)
    item = self.items.where('configuration_item_type_id = ?', configuration_item_type.id).first
    raise "Configuration item does not exist for configuration #{self.description}" if item.nil?
    item
  end

  alias :get_item :get_configuration_item

  #Clone
  #
  #Will copy all configuration item types
  #
  # * *Args*
  #   - +set_defaults+ -> create items and set default options
  # * *Returns* :
  #   - the cloned configuration
  def clone(set_defaults=false)
   configuration_dup = self.dup

    self.configuration_item_types.each do |configuration_item_type|
      configuration_dup.configuration_item_types << configuration_item_type
    end
    configuration_dup.save

    if set_defaults
      configuration_dup.configuration_item_types.each do |configuration_item_type|
        configuration_item = ConfigurationItem.create(:configuration_item_type => configuration_item_type)
        configuration_item.configuration_options = configuration_item_type.options.default
        configuration_item.save
        configuration_dup.configuration_items << configuration_item
      end
      configuration_dup.save
    end

    configuration_dup
  end

  #Copy
  #
  #Will copy all configuration item types and items
  #
  # * *Returns* :
  #   - the copied configuration
  def copy
    configuration_dup = self.clone

    #clone items
    self.configuration_items.each do |item|
      item_dup = item.dup
      item_dup.configuration_item_type = item.configuration_item_type
      item.configuration_options.each do |option|
        item_dup.configuration_options << option
      end
      item_dup.save
      configuration_dup.configuration_items << item_dup
    end

    configuration_dup.save
    configuration_dup
  end

end
