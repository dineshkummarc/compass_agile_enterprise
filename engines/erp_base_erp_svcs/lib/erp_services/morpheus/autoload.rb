require 'initializer' unless defined? ::Rails::Initializer
require 'action_controller/dispatcher' unless defined? ::ActionController::Dispatcher

module ErpServices
  module Morpheus

=begin rdoc
Searches for models that use <tt>has_morpheus</tt> and makes sure that they get loaded during app initialization.
This ensures that helper methods are injected into the target classes.
=end

    DEFAULT_OPTIONS = {
      :models => %w(ErpBaseErpSvcs::Currency Agreement PreferenceType)
    }

    mattr_accessor :options
    @@options = HashWithIndifferentAccess.new(DEFAULT_OPTIONS)

    # Dispatcher callback to load polymorphic relationships
    def self.autoload
      options[:models].each do |model|
        #try to load model if it exists.
        begin
          model.constantize
        rescue=>e
        end
      end
      
    end
  end
end

class Rails::Initializer #:nodoc:
  # Make sure it gets loaded in the console, tests, and migrations
  def after_initialize_with_autoload
    after_initialize_without_autoload
    ErpServices::Morpheus.autoload
  end
  alias_method_chain :after_initialize, :autoload
end

ActionController::Dispatcher.to_prepare(:morpheus_autoload) do
  # Make sure it gets loaded in the app
  ErpServices::Morpheus.autoload
end