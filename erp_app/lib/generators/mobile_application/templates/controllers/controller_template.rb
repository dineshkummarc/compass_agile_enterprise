module ErpApp
	module Mobile
    module <%= class_name %>
      class BaseController < ::ErpApp::Mobile::BaseController
        def index
          @application = MobileApplication.find_by_internal_identifier('<%= file_name%>')
        end
      end
    end
  end
end