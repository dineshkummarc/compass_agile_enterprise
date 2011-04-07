module Tenancy
  module Controller
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def check_tenants
        before_filter :set_search_path
        after_filter  :reset_search_path

        extend Tenancy::Controller::SingletonMethods
        include Tenancy::Controller::InstanceMethods
      end
    end

    module SingletonMethods
		end

		module InstanceMethods
      def set_search_path
        host_with_port = "#{request.host}:#{request.port}"
        schema = Tenant.find_schema_by_host(host_with_port)
        Tenancy::SchemaUtil.set_search_path(schema)
      end

      def reset_search_path
        Tenancy::SchemaUtil.reset_search_path
      end
    end

  end
end

ActionController::Base.send(:include, Tenancy::Controller)