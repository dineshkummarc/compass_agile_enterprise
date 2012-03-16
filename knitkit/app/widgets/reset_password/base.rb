module Widgets
  module ResetPassword
    class Base < ErpApp::Widgets::Base

      def index
        @website   = Website.find_by_host(request.host_with_port)
        @login_url = params[:login_url]
        @domain    = @website.configurations.first.get_item(ConfigurationItemType.find_by_internal_identifier('primary_host')).options.first.value

        render
      end

      #should not be modified
      #modify at your own risk
      def locate
        File.dirname(__FILE__)
      end

      class << self
        def title
          "Reset Password"
        end

        def widget_name
          File.basename(File.dirname(__FILE__))
        end

        def base_layout
          begin
            file = File.join(File.dirname(__FILE__),"/views/layouts/base.html.erb")
            IO.read(file)
          rescue
            return nil
          end
        end
      end
    end
  end
end

