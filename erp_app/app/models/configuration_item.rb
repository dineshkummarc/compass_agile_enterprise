class ConfigurationItem < ActiveRecord::Base
  belongs_to :configuration
  belongs_to :configuration_item_type
  has_and_belongs_to_many :configuration_options

  alias :config :configuration
  alias :options :configuration_options
  alias :type :configuration_item_type

  def to_js_hash
    {:id => self.id,
      :configruationItemType => self.type.to_js_hash,
      :configurationOptions => options.collect(&:to_js_hash)
    }
  end

  def clear_options
    if self.configuration_item_type.allow_user_defined_options?
      self.options.destroy_all
    else
      self.options.delete_all
    end
    self.save
  end

  def set_options(internal_identifiers_or_value)
    internal_identifiers_or_value.flatten! if internal_identifiers_or_value.is_a?(Array)
    if self.configuration_item_type.allow_user_defined_options?
      unless internal_identifiers_or_value.blank?
        value = internal_identifiers_or_value.join("")
        option = ConfigurationOption.find_by_value(value)
        self.options << (option ? option : ConfigurationOption.create(:value => value))
      end
    elsif self.configuration_item_type.is_multi_optional?
      internal_identifiers_or_value.split(',').each do |internal_identifier|
        self.options << self.configuration_item_type.find_configuration_option(internal_identifier)
      end
    else
      self.options << self.configuration_item_type.find_configuration_option(internal_identifiers_or_value)
    end

    self.save
  end
end
