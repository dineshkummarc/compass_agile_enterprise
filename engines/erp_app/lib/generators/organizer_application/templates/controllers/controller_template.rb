class ErpApp::Organizer::<%= class_name %>::BaseController < ErpApp::Organizer::BaseController

  def menu
    ext_json = '['

    ext_json += '{text:"Menu Item", id:"menu_item", leaf:true, iconCls:"icon-data", href:"javascript:void(\'\');Compass.Component.UserApp.Util.setActiveCenterItem(\'<%= file_name %>_example_panel\');"}'

    ext_json += ']'

    render :inline => ext_json
  end

end