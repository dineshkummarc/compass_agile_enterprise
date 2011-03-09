# BASE RESERVATIONS CONTROLLER, OL RESERVATIONS EXTEND THIS, THIS EXTENDS STORE BASE CONTROLLER
class BaseApps::Ecommerce::ReservationsBaseController < BaseApps::Ecommerce::StoreBaseController
  
  def init_reservation

     #*******************************************************************
    # Determine if we are working on an order-in-progress
    #*******************************************************************

    if session[:reservation_id]
      o = ReservationTxn.find(session[:reservation_id])
    else

      #*******************************************************************
      # Setting up the transaction and account party roles should be
      # factored into a "create_order" method or similar
      #*******************************************************************
      o = ReservationTxn.new

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

      session[:reservation_id] = o.id
    end
    
    return o
  end

  
  def place_order(cvv)
    @page_title = "Checkout"
    @txn = ReservationTxn.find(session[:reservation_id])

    @txn.biz_txn_event.biz_txn_type = BizTxnType.find_by_internal_identifier('ecommerce') || nil # set default txn type here

    # we use card on file
    @credit_card = @party.primary_credit_card

    @txn.credit_card_id = @credit_card.id

    @txn.email = 'test@test.com'
    @txn.phone_number = '1234567'

    @txn.ship_to_first_name = @party.first_name
    @txn.ship_to_last_name = @party.last_name
    @txn.ship_to_address = @party.shipping_address.address_line_1
    @txn.ship_to_city = @party.shipping_address.city
    @txn.ship_to_state = @party.shipping_address.state
    @txn.ship_to_postal_code = @party.shipping_address.zip
    @txn.ship_to_country = @party.shipping_address.country

    @txn.bill_to_first_name = @party.first_name
    @txn.bill_to_last_name = @party.last_name
    @txn.bill_to_address = @credit_card.postal_address.address_line_1
    @txn.bill_to_city = @credit_card.postal_address.city
    @txn.bill_to_state = @credit_card.postal_address.state
    @txn.bill_to_postal_code = @credit_card.postal_address.zip
    @txn.bill_to_country = @credit_card.postal_address.country

    @txn.customer_ip = request.remote_ip

    if @txn.save
      if @txn.process(@credit_card, cvv )
        # save credit card here because we now know it is a good card
        @credit_card.save

        flash.now[:notice] = 'Your order has been submitted, and will be processed immediately.'
        session[:reservation_id] = @txn.id
        # Empty the cart
        session[:reservation_id] = nil

      else
        flash.now[:notice] = "Error while processing order. '#{@txn.error_message}'"

      end
    else

      flash.now[:notice] = "Error while placing order. '#{error_messages_for('order_txn')}'"

    end
  end
  
end