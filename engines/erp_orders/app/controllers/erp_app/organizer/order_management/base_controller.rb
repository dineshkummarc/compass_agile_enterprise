class ErpApp::Organizer::OrderManagement::BaseController < ErpApp::Organizer::BaseController

  def menu
    menu = []

    menu << {:text => 'Orders', :leaf => true, :iconCls => 'icon-package', :applicationCardId => "orders_layout"}

    render :inline => menu.to_json
  end

end