module ErpApp
  module Organizer
    module <%= class_name %>
      class BaseController < ::ErpApp::Organizer::BaseController
        def menu
          render :inline => [{:text => 'Menu Item', :leaf => true, :iconCls => '<%=icon %>', :applicationCardId => "<%= file_name %>_example_panel"}].to_json
        end
      end#BaseController
    end#<%= class_name %>
  end#Organizer
end#ErpApp