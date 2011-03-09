# base store controller, extend this for other purposes
class BaseApps::Ecommerce::StoreBaseController < ApplicationController
  include TechServices::Authentication::CompassAuthentication
  #helper TechServices::Geo::GeoHelper
  #helper ErpServices::Ecommerce::CreditCardHelper

  layout('base_apps/ecommerce/layouts/application')

  #  before_filter :login_required
  before_filter :load_current_party_from_session
  before_filter :set_store_id
  before_filter :get_credit_card_info
  before_filter :set_party_defaults

  def index
  end

  def update_credit_card
  end
  
  def update_billing_address
  end
  
  def update_shipping_address
  end  
  
  def get_item

    search_fact = AccomInvSearchFact.find(params[:id])
    inv_entry = search_fact.inventory_entry

    return inv_entry
  end

  def init_order

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

    return o
  end

  def put_item_in_cart(inv_entry)

    o = init_order

    li = OrderLineItem.new
    li.product_description = inv_entry.description
    li.product_type_id = inv_entry.product_type_id

    o.line_items << li
    o.description = li.product_description

    li.save
    o.save

    return o
  end

  def add_to_cart

    #puts '*********************************************************************************'
    #puts current_user.party.to_yaml
    # puts session[:current_party_id]
    # puts @current_party.to_yaml
    #puts '*********************************************************************************'

    inv_entry = self.get_item(params[:id])
    @order_txn = put_item_in_cart(inv_entry)

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
    if session[:order_id]
      @order_txn = OrderTxn.find(session[:order_id])
    else
      redirect_to :action => 'index'
      return
    end

    #@order_txn.submit!

    checkout_template

  end

  def place_order
    @page_title = "Checkout"
    @order_txn = OrderTxn.find(session[:order_id])

    @order_txn.biz_txn_event.biz_txn_type = BizTxnType.find_by_internal_identifier('ecommerce') || nil # set default txn type here

    if params[:order][:card_on_file].eql?('0')
      # we add a new card
      @credit_card = ErpServices::Ecommerce::CreditCard.new

      @ccapr =  ErpServices::Ecommerce::CreditCardAccountPartyRole.new
      @ccapr.party = @party
      @ccapr.role_type = RoleType.find_by_internal_identifier('primary_owner') # set default role type here
      @ccapr.credit_card_account = ErpServices::Ecommerce::CreditCardAccount.new

      @credit_card.credit_card_account_party_role = @ccapr

      @credit_card.card_number = params[:order][:card_number]
      @credit_card.card_type = params[:order][:card_type]
      @credit_card.expiration_month = params[:order][:card_expiration_month]
      @credit_card.expiration_year = params[:order][:card_expiration_year]

      @credit_card.postal_address = PostalAddress.new # set default billing address here
      @credit_card.postal_address.address_line_1 = params[:order][:bill_to_address]
      @credit_card.postal_address.city = params[:order][:bill_to_city]
      @credit_card.postal_address.state = params[:order][:bill_to_state]
      @credit_card.postal_address.zip = params[:order][:bill_to_postal_code]
      @credit_card.postal_address.country = params[:order][:bill_to_country]
      @credit_card.postal_address.description = 'billing address'

      @credit_card.postal_address.geo_country_id = GeoCountry.find_by_iso_code_2(params[:order][:bill_to_country]).id
      @credit_card.postal_address.geo_zone_id = GeoZone.find_by_zone_code(params[:order][:bill_to_state]).id if params[:order][:bill_to_state]

      @credit_card.first_name_on_card = params[:order][:card_first_name]
      @credit_card.last_name_on_card = params[:order][:card_last_name]

    else
      # we use card on file
      @credit_card = ErpServices::Ecommerce::CreditCard.find(params[:order][:card_on_file])
    end

    @order_txn.credit_card_id = @credit_card.id

    @order_txn.email = params[:order][:email]
    @order_txn.phone_number = params[:order][:phone_number]

    @order_txn.ship_to_first_name = params[:order][:ship_to_first_name]
    @order_txn.ship_to_last_name = params[:order][:ship_to_last_name]
    @order_txn.ship_to_address = params[:order][:ship_to_address]
    @order_txn.ship_to_city = params[:order][:ship_to_city]
    @order_txn.ship_to_state = params[:order][:ship_to_state]
    @order_txn.ship_to_postal_code = params[:order][:ship_to_postal_code]
    @order_txn.ship_to_country = params[:order][:ship_to_country]

    @order_txn.bill_to_first_name = params[:order][:bill_to_first_name]
    @order_txn.bill_to_last_name = params[:order][:bill_to_last_name]
    @order_txn.bill_to_address = @credit_card.postal_address.address_line_1
    @order_txn.bill_to_city = @credit_card.postal_address.city
    @order_txn.bill_to_state = @credit_card.postal_address.state
    @order_txn.bill_to_postal_code = @credit_card.postal_address.zip
    @order_txn.bill_to_country = @credit_card.postal_address.country

    @order_txn.customer_ip = request.remote_ip

    if @order_txn.save
      if @order_txn.process(@credit_card, params[:order][:card_verification_value] )
        # save credit card here because we now know it is a good card
        @credit_card.save

        flash.now[:notice] = 'Your order has been submitted, and will be processed immediately.'
        session[:order_id] = @order_txn.id
        # Empty the cart
        session[:order_id] = nil

        respond_to do |format|
          format.js do
            render :update do |page|
              page.replace_html 'error', :partial => 'error'
              page.replace_html 'content', :partial => 'thank_you'
              page.replace_html 'cart', :partial => 'cart'
            end
          end
        end
      else
        flash.now[:notice] = "Error while placing order. '#{@order_txn.error_message}'"

        respond_to do |format|
          format.js do
            render :update do |page|
              page.replace_html 'error', :partial => 'error'
            end
          end
        end
      end
    else

      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace_html 'error', :partial => 'error'
          end
        end
        format.html {
          render :action => 'check_out'
        }
      end
    end
  end

  def switch_billing_address
    @order_txn = OrderTxn.find(session[:order_id])

    if params[:country] != '0'
      @credit_card = ErpServices::Ecommerce::CreditCard.find(params[:country])
      @billing_address = @credit_card.postal_address
    end

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'billing_address', :partial => 'billing_address'
        end
      end
    end
  end

  def state_select_box
    @order_txn = OrderTxn.find(session[:order_id])
    @selected_country = params[:country]

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html params[:div], :partial => 'state_select', :locals => {:name => params[:name] }
        end
      end
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

  def get_txn_party_role(iid=nil)
    if(!iid.blank?)
      return BizTxnPartyRoleType.find_by_internal_identifier(iid)
    end
    role_type = nil
  end

  def guide_transaction_to_account( current_party, txn_type = nil, role_type = nil, option_hash = {} )
    acct = current_party.default_account
  end

  def checkout_template
    render :template => '/base_apps/ecommerce/store/check_out'
  end

  def render_thank_you_template
    render :template => '/base_apps/ecommerce/store/thank_you'
  end

  # override the 'compass_application_logon_path' defined in CompassAuthentication
  def compass_application_logon_path
    return "/ecommerce/login"
  end

  def set_party_defaults

    #@party = get_party
    #@party = Party.find_by_enterprise_identifier('250060')
    
    # for agent view, use selected party, otherwise use current_user.party
    if session[:selected_party_id]
      @party = Party.find(session[:selected_party_id]) 
    else
      @party = current_user.party
    end

    # get billing address
    @billing_address = @party.find_contact_mechanism_with_purpose(PostalAddress, ContactPurpose.find_by_internal_identifier('billing'))

    # get shipping address
    @shipping_address = @party.find_contact_mechanism_with_purpose(PostalAddress, ContactPurpose.find_by_internal_identifier('shipping'))

    # get phone number
    @phone_number = @party.primary_phone_number.phone_number

    # get email address
    @email_address = @party.primary_email_address.email_address unless @party.primary_email_address.nil?

    # get credit card
    @credit_card = nil

    get_credit_card_info()
  end

  private
  
  def get_credit_card_info
    credit_card = nil
    unless params[:card_number].blank?
      credit_card = {}
      credit_card[:charge_amount] = params[:amount]
      credit_card[:number]        = params[:card_number]
      credit_card[:exp_month]     = params[:exp_month]
      credit_card[:exp_year]      = params[:exp_year]
      credit_card[:type]          = params[:card_type]
      credit_card[:cvvs]          = params[:cvvs]
      credit_card[:name_on_card]  = params[:name_on_card]
      credit_card[:billing_zip]   = params[:billing_zip_code]
    end
    
    @credit_card = credit_card
  end
end
