class ErpApp::Organizer::<%= class_name %>::BaseController < ErpApp::Organizer::BaseController

  def menu
    menu = []

    menu << {:text => 'Menu Item', :id => 'menu_item', :leaf => true, :iconCls => '', :href => "javascript:void(\'\');Compass.Component.UserApp.Util.setActiveCenterItem(\'<%= file_name %>_example_panel\');"}

    render :inline => menu.to_json
  end

end