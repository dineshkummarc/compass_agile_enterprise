class Configuration < ActiveRecord::Base
  scope :templates, where('is_template = ?', true)

  validates :internal_identifier, :presence => true, :uniqueness =>  {:scope => [:id, :is_template]}
  validates :is_template, :uniqueness => {:scope => :internal_identifier}

  has_many :configuration_items, :dependent => :destroy do
    def by_category(category)
      includes({:configuration_item_type => [:category_classification]}).where(:category_classifications => {:category_id => category})
    end

    def grouped_by_category
      group_by(&:category)
    end
  end
  has_and_belongs_to_many :configuration_item_types, :uniq => true do
    def by_category(category)
      includes(:category_classification).where(:category_classifications => {:category_id => category})
    end

    def grouped_by_category
      group_by(&:category)
    end
  end
  
  alias :items :configuration_items
  alias :item_types :configuration_item_types

  def is_template?
    self.is_template
  end

  def add_configuration_item(configuration_item_type, *option_internal_identifiers)
    item = get_configuration_item(configuration_item_type)
    if item
      update_configuration_item(configuration_item_type, option_internal_identifiers)
    else
      unless self.configuration_item_types.where("id = ?", configuration_item_type.id).first.nil?
        item = ConfigurationItem.create(:configuration_item_type => configuration_item_type)
        item.set_options(option_internal_identifiers)
        self.configuration_items << item
        self.save
      else
        raise "Configuration Item Type #{configuration_item_type.description} is not valid for this configuration"
      end
    end
  end

  alias :add_item :add_configuration_item

  def update_configuration_item(configuration_item_type, *option_internal_identifiers)
    item = self.items.where('configuration_item_type_id = ?', configuration_item_type.id).first
    raise "Configuration item #{configuration_item_type.description} does not exist for configuration #{self.description}" if item.nil?

    item.clear_options
    item.set_options(option_internal_identifiers.flatten)
  end

  alias :update_item :update_configuration_item

  def get_configuration_item(configuration_item_type)
    self.items.where('configuration_item_type_id = ?', configuration_item_type.id).first
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
    configuration_dup.internal_identifier = "#{self.internal_identifier} clone"
    configuration_dup.description = "#{self.description} clone"
    configuration_dup.is_template = false

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
    configuration_dup.internal_identifier = "#{self.internal_identifier} copy"
    configuration_dup.description = "#{self.description} copy"

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

  class << self
    def find_template(iid)
      self.templates.where('internal_identifier = ?', iid).first
    end
  end

end
