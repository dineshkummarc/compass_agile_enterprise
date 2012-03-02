module ErpApp
  module Organizer
    class <%= class_name %>::BaseController < ::ErpApp::Organizer::BaseController
      def menu
        menu = []

        menu << {:text => 'Menu Item', :leaf => true, :iconCls => '<%=icon %>', :applicationCardId => "<%= file_name %>_example_panel"}

        render :inline => menu.to_json
      end
    end
  end
end