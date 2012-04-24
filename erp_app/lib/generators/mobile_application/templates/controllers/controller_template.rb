module ErpApp
	module Mobile
    module <%= class_name %>
      class BaseController < ::ErpApp::Mobile::BaseController
        def index
          @application = MobileApplication.find_by_internal_identifier('<%= file_name%>')
        end
      end#BaseController
    end#<%= class_name %>
  end#Mobile
end#ErpApp