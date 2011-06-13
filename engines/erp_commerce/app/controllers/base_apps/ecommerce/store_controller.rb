class BaseApps::Ecommerce::StoreController < ApplicationController
  include TechServices::Authentication::CompassAuthentication
  layout('base_apps/ecommerce/layouts/application')

#  before_filter :login_required
  before_filter :load_current_party_from_session
  before_filter :set_store_id
#  before_filter "login_required(nil)"
     
  def index
  end

  def add_to_cart
    
    #puts '*********************************************************************************'
    #puts current_user.party.to_yaml
    # puts session[:current_party_id]
    # puts @current_party.to_yaml
    #puts '*********************************************************************************'
        
    search_fact = AccomInvSearchFact.find(params[:id])
    inv_entry = search_fact.inventory_entry
       
    #*******************************************************************
    # Determine if we are working on an order-in-progress
    #*******************************************************************
       
    if session[:order_id] 
      o = OrderTxn.find(session[:order_id])
    else
    
      #*******************************************************************
      # Setting up the transaction and account party roles should be
      # factored into a "create_order" method or similar
      #*******************************************************************
    
      o = OrderTxn.new
      o.save
      
      #*******************************************************************
      # Determine the account to which this transaction should be guided.
      #
      # Delegate to subclasses in most cases. The default algorithm below
      # will simply return the default account for this party
      #*******************************************************************
      # acct = guide_transaction_to_account( @current_party )
      # 
      tpr = BizTxnPartyRole.new
      tpr.biz_txn_event = o.root_txn
      # tpr.account = acct
      tpr.party = current_user.party
    
      #*******************************************************************
      # Another hook method, allowing subclasses to determine what role
      # types are being played in the creation of a transaction.
      #
      # This one will need to eventually be replaced so that multiple
      # TransactionPartyRoles can be created for each TransactionEvent
      #*******************************************************************
      tpr.biz_txn_party_role_type = get_txn_party_role
      tpr.save     
      o.save
      
      session[:order_id] = o.id
                  
    end

    li = OrderLineItem.new
    li.product_description = inv_entry.description
    
    o.line_items << li
    o.description = li.product_description
    
    li.save
    o.save
    @order_txn = o

    respond_to do |format|
      format.js {
        render( :partial => "cart", :object => @order_txn )
      }
      format.html{
        redirect_to :back
      }
    end
          
  end  

  def empty_cart
    
    o = OrderTxn.find(session[:order_id]).destroy
    session[:order_id] = nil

    respond_to do |format|
      format.js {
        render( :partial => "cart" )
      }
      format.html{
        redirect_to :back
      }
    end    
    
    
  end
  
  def check_out
    
    puts "check out called"
    @order_txn = OrderTxn.find(session[:order_id])
    @order_txn.submit!

    checkout_template 
  
  end

  def place_order

    @page_title = "Checkout" 
    @order_txn = OrderTxn.find(session[:order_id])
    @order_txn.customer_ip = request.remote_ip 

    if @order_txn.save 
      if @order_txn.process 
        flash[:notice] = 'Your order has been submitted, and will be processed immediately.' 
        session[:order_id] = @order_txn.id 
        # Empty the cart 
        session[:order_id] = nil
        redirect_to :action => 'thank_you' 
      else 
        flash[:notice] = "Error while placing order. '#{@order_txn.error_message}'" 
        render :action => 'index' 
      end 
    else 
      render :action => 'index' 
    end      
    
  end

  def thank_you
    render_thank_you_template
  end

  protected
  
  def load_current_party_from_session
    if session[:current_party_id]
      @current_party = Party.find(session[:current_party_id])
    end   
  end
  
  def set_store_id
    #set the default store id
    session[:store_id] = 0
  end

  def get_txn_party_role
    role_type = nil
  end

  def guide_transaction_to_account( current_party, txn_type = nil, role_type = nil, option_hash = {} )
    acct = current_party.default_account
  end

  def checkout_template
    render :template => '/crm/store/check_out'
  end

  def render_thank_you_template
    render :template => '/crm/store/thank_you'    
  end

  # override the 'compass_application_logon_path' defined in CompassAuthentication
  def compass_application_logon_path
    return "/ecommerce/login"
  end
  
end
