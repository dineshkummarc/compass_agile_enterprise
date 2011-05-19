
# == Basic overview
# Based on ideas and code snippits from Cell plugin this library allows you
# to imbed a reusable component into view that is decoupled from the controller
# and view it resides in. It can have its own MVC lifecycle independent of its parent
# view.

require 'action_controller/base'

module ErpApp
  module Widgets
    class Base
      attr_accessor :controller
      attr_accessor :name
      attr_accessor :view

      include ::ActionController::Helpers
      include ::ActionController::RequestForgeryProtection
      include ::ActionController::Cookies

      class_inheritable_array :view_paths, :instance_writer => false
      write_inheritable_attribute(:view_paths, ActionView::PathSet.new) # Force use of a PathSet in this attribute, self.view_paths = ActionView::PathSet.new would still yield in an array


      class << self
        attr_accessor :request_forgery_protection_token
      
        def add_view_path(path)
          path = File.join(::Rails.root, path) if defined?(::Rails) and ::Rails.respond_to?(:root)
          self.view_paths << path unless self.view_paths.include?(path)
        end

        def initialize_view_paths
          self.view_paths = []
        end
      end

      class_inheritable_accessor :allow_forgery_protection
      self.allow_forgery_protection = true

      class_inheritable_accessor :default_template_format
      self.default_template_format = :html

      delegate :params, :session, :request, :logger, :authenticated?, :to => :controller

      attr_accessor :controller
      attr_reader   :state_name


      def initialize(controller, name, view)
        self.name = name
        self.controller = controller
        self.view = view
      end

      def setup_action_view
        view_class  = Class.new(ErpApp::Widgets::View)
        view_paths = ActionView::PathSet.new
        #get the view path based on the location of the class being executed
        view_paths << File.join(self.locate.gsub("#{RAILS_ROOT}/",''), 'views')
        action_view = view_class.new(view_paths, {}, @controller)
        action_view
      end

      def prepare_action_view_for(action_view)
        # make helpers available:
        include_helpers_in_class(action_view.class)

        action_view.assigns = assigns_for_view  # make instance vars available.
      end

      # When passed a copy of the ActionView::Base class, it
      # will mix in all helper classes for this cell in that class.
      def include_helpers_in_class(view_klass)
        view_klass.send(:include, self.class.master_helper_module)
      end

      # Prepares the hash {instance_var => value, ...} that should be available
      # in the ActionView when rendering the state view.
      def assigns_for_view
        assigns = {}
        (self.instance_variables - ivars_to_ignore).each do |k|
          assigns[k[1..-1]] = instance_variable_get(k)
        end
        assigns
      end

      # Defines the instance variables that should <em>not</em> be copied to the
      # View instance.
      def ivars_to_ignore;  ['@controller']; end

      def render(opts={})
        view = opts[:view] || self.view
        action_view = setup_action_view
        view_template = nil
        missing_template_exception = nil

        prepare_action_view_for(action_view)

        begin
          view_template = action_view.try_picking_template_for_path(view.to_s)
        rescue ::ActionView::MissingTemplate => missing_template_exception
        end

        raise missing_template_exception unless missing_template_exception.nil?

        action_view.render({:file => view_template, :template_format => :html})
      end

      protected
      #get location of this class that is being executed
      def locate
        File.dirname(__FILE__)
      end

    end
  end
end