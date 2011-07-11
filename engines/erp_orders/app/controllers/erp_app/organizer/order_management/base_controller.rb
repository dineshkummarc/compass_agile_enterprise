class ErpApp::Organizer::OrderManagement::BaseController < ErpApp::Organizer::BaseController

  def menu
    menu = []

    menu << {:text => 'Orders', :id => 'orders', :leaf => true, :iconCls => 'icon-package', :href => "javascript:void(\'\');Compass.Component.UserApp.Util.setActiveCenterItem(\'orders_layout\');"}

    render :inline => menu.to_json
  end

end