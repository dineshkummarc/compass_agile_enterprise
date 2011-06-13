class BaseApps::Ecommerce::OrderMgtController < ApplicationController
  include TechServices::Authentication::CompassAuthentication
  layout('base_apps/ecommerce/layouts/application')
  before_filter :load_current_party_from_session
  
  before_filter "login_required(nil)"
  
 
  def index
  end

  def list_by_party_role
    
    if session[:current_party_id]
      party = session[:current_party_id]
      @orders = OrderTxn.find( :all, :include => { :transaction_event => :transaction_party_roles }, :conditions => "transaction_party_roles.party_id = #{@party.id}")
    else
      @orders = []
    end

    list_by_party_role_template
    
  end

  # def new
  #   @record = OrderTxn.new
  #   #the date/time selector requires this hack
  #   @order = @record
  #   
  #   session[:line_item_index] = 0
  #   #needed so the ajax calls can have access to
  #   #an ownership instance to add owners to
  #   session[:order_id] = @record.id  
  #       
  #   render :partial => 'new'
  # 
  # end

  # def create
  #   
  #   if session[:order_id]
  #     @record = OrderTxn.find(session[:order_id])
  #     @record.update_attributes(params[@klass_symbol])
  #   else
  #     @record = OrderTxn.new(params[@klass_symbol])
  #     @record.save
  #     session[:order_id] = @record.id
  #   end    
  # 
  #   if @record.save             
  #     flash[:notice] = OrderTxn.to_s + ' was successfully created.'
  #     redirect_to :back
  #   else
  #     render :action => 'new'
  #   end
  # end

  # def edit   
  #   @record = OrderTxn.find(params[:id])   
  #   session[:line_item_index] = @record.line_items.count    
  #   render :partial => 'edit'  
  # end
  # 
  # def update
  # 
  #   @record = OrderTxn.find(params[:id])
  #   @record.update_attributes(params[@klass_symbol])    
  # 
  # 
  #   if @record.save
  #      
  #     flash[:notice] = OrderTxn.to_s + ' was successfully updated.'
  #     redirect_to :back
  #     
  #   else
  #     render :action => 'edit'
  #   end
  # end
  # 
  # def add_description_for_line_item
  #   
  #   desc = params[:line_item_description]  
  #   session[:line_item_description] = desc
  #       
  #   render :partial => 'line_items'   
  #   
  # end
  # 
  # def add_product_for_line_item
  #   
  #   desc = params[:product]  
  #   p_id = desc.split(':')[0].strip.to_i
  #   session[:product_id] = RoleType.find(p_id)
  #       
  #   render :partial => 'line_items'   
  #   
  # end
  # 
  # def create_order_line_item()
  #   
  #   puts '*******************************************'
  #   puts params.to_yaml
  #  
  #   if session[:order_id]
  #     @record = OrderTxn.find(session[:order_id])
  #   else
  #     @record = OrderTxn.new(params[@klass_symbol])
  #     @record.save
  #     session[:order_id] = @record.id
  #   end
  #   
  #   li = OrderLineItem.new(params[:line_item])
  #   li.description = session[:line_item_description]
  #   li.product = Product.find(session[:product_id])
  #           
  #   @record.line_items << li
  #   @record.save
  # 
  #   render :partial => 'line_items'
  #         
  # end


  protected

  def load_current_party_from_session
    if session[:current_party_id]
      @current_party = Party.find(session[:current_party_id])
    end
  end

  def list_by_party_role_template
	  render :template => '/base_apps/ecommerce/order_mgt/list_by_party_role'
  end

  # override the 'compass_application_logon_path' defined in CompassAuthentication
  def compass_application_logon_path
    return "/ecommerce/login"
  end
end
