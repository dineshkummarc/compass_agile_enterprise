class ConfigurationItemType < ActiveRecord::Base
  validates :internal_identifier, :uniqueness => {:scope => :id}

  has_and_belongs_to_many :configuration_options do
    def default
      where('is_default = ?', true)
    end
  end
  has_many :configuration_items, :dependent => :destroy
  has_many :category_classifications, :as => :classification, :dependent => :destroy

  alias :options :configuration_options

  def add_default_configuration_option(option)
    existing_option = self.configuration_options.where(:id => option.id).first
    if existing_option.nil?
      ConfigurationItemTypeConfigurationOption.create(:configuration_item_type => self, :configuration_option => option, :is_default => true)
    else
      configuration_item_type_configuration_option = ConfigurationItemTypeConfigurationOption.where('configuration_option_id = ? and configuration_item_type_id = ?', existing_option.id, self.id)
      configuration_item_type_configuration_option.is_default = true
      configuration_item_type_configuration_option.save
    end
  end

  alias :add_default_option :add_default_configuration_option

  def is_multi_optional?
    self.is_multi_optional
  end

  def allow_user_defined_options?
    self.allow_user_defined_options
  end

  def find_configuration_option(internal_identifier, type=:internal_identifier)
    option = self.options.where("#{type.to_s} = ?", internal_identifier).first
    raise "Option #{internal_identifier} does not exist for configuration item type #{self.description}" if option.nil?
    option
  end

  def clear_options
    self.options.delete_all
    self.save
  end

  def to_js_hash
    {:id => self.id,
      :description => self.description,
      :internalIdentifier => self.internal_identifier,
      :configurationOptions => configuration_options.collect(&:to_js_hash),
      :defaultOptions => self.options.default.collect(&:to_js_hash),
      :isMultiOptional => self.is_multi_optional,
      :allowUserDefinedOptions => self.allow_user_defined_options
    }
  end

end
