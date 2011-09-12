class ErpApp::Widgets::ProductCatalog::Base < ErpApp::Widgets::Base
  def index
    render
  end

  def show
    @product_type = ProductType.find(params[:id])
    render
  end

  def add_to_cart
    @product_type   = ProductType.find(params[:id])
    @cart_items_url = params[:cart_items_url]
    ErpApp::Widget::ShoppingCart::Helpers::Order.new(self).add_to_cart(@product_type)
    
    render
  end
  
  #if module lives outside of erp_app plugin this needs to be overriden
  #get location of this class that is being executed
  def locate
    File.dirname(__FILE__)
  end
  
end
