module ErpApp
	module Mobile
		module OnlineBooking
      class BaseController < ErpApp::Mobile::BaseController
        def index
          @application = MobileApplication.find_by_internal_identifier('online_booking')
        end

        def search
          begin

            check_in_date = params[:check_in_date].to_date
            check_out_date = params[:check_out_date].to_date

            if check_in_date > check_out_date
              @error = 'Check out date can not be before check in date'
              render :view => :error
            else
              sql = "select
                apt.*
                from
                inventory_entries ie
                join
                product_types pt on ie.product_type_id = pt.id
                join
                accom_product_types apt on apt.id = pt.product_type_record_id
                join
                accomodation_unit_types aut on aut.id = apt.accomodation_unit_type_id
                where
                apt.night >= '#{check_in_date}'
                and
                apt.night <  '#{check_out_date}'
                and
                ie.number_available > 0
                order by aut.id, night"
              accom_product_types = AccomProductType.find_by_sql(sql)

              @packages = package_results(accom_product_types, (check_out_date - check_in_date).to_i)
            end

          rescue Exception=>ex
            logger.error ex.message
            logger.error ex.backtrace.join("\n")
            @error = 'Error Searching'

          end

          render :json => {:success => true, :packages => @packages}
        end

        def book
          @unit_type      = AccomodationUnitType.find(params[:unit_type_id])
          @check_in_date  = params[:check_in_date]
          @check_out_date = params[:check_out_date]
          @usd_price      = params[:usd_price]
          @nights         = params[:nights]

          render :update => {:id => "#{@uuid}_result", :view => :book}
        end

        def submit
          begin
            set_enviroment_variables
            @order = build_order
            place_order(@order)
          rescue Exception=>ex
            logger.error ex.message
            logger.error ex.backtrace.join("\n")
            @error = 'Error Booking'
          end

          view = @error ? :error : :success
          render :update => {:id => "#{@uuid}_result", :view => view}
        end

        protected

        def init_order
          if session[:reservation_id]
            res = ReservationTxn.find(session[:reservation_id])
          else

            res = ReservationTxn.new
            res.determine_txn_type
            res.order_number = Time.now.to_i
            res.travel_to_date = params[:check_out_date].to_date
            res.travel_from_date = params[:check_in_date].to_date
            res.reserved_date = Date.today

            session[:reservation_id] = res.id
          end
          res
        end

        def build_order
          order = init_order

          #order.determine_charge_accounts(:app_name => 'CmpssAV',:ownership_id => params[:ownership_id])

          party = order.create_traveler_party(get_traveler_information)

          order.determine_txn_party_roles(party)
          #order.determine_txn_agreement_roles(:app_name => 'CmpssAV',:ownership_id => params[:ownership_id], :home_access_agreement_id => params[:home_access_agreement_id])

          #if you want a phyiscal room use this.
          accom_unit = order.find_available_unit(params[:unit_type_id], params[:check_in_date].to_date, params[:check_out_date].to_date)

          order.add_line_item(
            :check_in_date => params[:check_in_date].to_date,
            :check_out_date => params[:check_out_date].to_date,
            :nights => params[:nights],
            #if you want just the type
            #:accomodation_unit_type_ids => [params[:unit_type_id]]
            :accomodation_unit_ids => [accom_unit.id]
          )

          order.status = 'order initialized'

          order.determine_charge_elements(:enviroment_facts => @enviroment_variables, :price => params[:usd_price])
          order
        end

        def place_order(order)
          payor = order.find_party_by_role('payor')
          traveler = order.find_party_by_role('traveler')
          order.set_billing_info(payor)
          order.set_shipping_info(traveler)
          order.customer_ip = @enviroment_variables[:remote_ip]

          #take creditcard
          order.update_product_availability
          order.status = "Complete"
          order.save
        end

        def set_enviroment_variables
          @enviroment_variables = {
            :time => Time.now.utc,
            :user_agent => request.env["HTTP_USER_AGENT"],
            :url => request.url,
            :remote_ip => request.remote_ip,
          }
        end

        def get_traveler_information
          travler_information = {}
          travler_information[:first_name] = params[:first_name]
          travler_information[:last_name] = params[:last_name]

          travler_information[:email_address] = params[:email]
          travler_information[:phone_number] = params[:phone]

          travler_information[:address_line_1] = params[:address_line_1]
          travler_information[:address_line_2] = params[:address_line_2]
          travler_information[:city] = params[:city]
          travler_information[:state] = params[:state]
          travler_information[:zip] = params[:zipcode]
          travler_information[:country] = params[:country]

          travler_information
        end

        def package_results(accom_product_types, nights)
          packages = []
          package = nil
          accom_product_types.each do |accom_product_type|
            #if this is a different resort/unit-type, start a new record to capture its # of nights
            if( (package == nil) ||
                  (accom_product_type.accomodation_unit_type_id != package[:unit_type_id]) ||
                  (accom_product_type.night > (package[:check_in_date] + package[:nights].days))  )

              package = {
                :image_url => "/images/timeshare/rooms/#{accom_product_type.accomodation_unit_type.internal_identifier}_100x100.jpg",
                :check_in_date => accom_product_type.night,
                :check_out_date => (accom_product_type.night + nights.days),
                :nights => 0,
                :unit_type_id => accom_product_type.accomodation_unit_type_id,
                :number_available => [],
                :price => 0,
                :description => accom_product_type.accomodation_unit_type.find_descriptions_by_view_type('search_result_details').first.description
              }
              packages << package
            end

            package[:nights] += 1
            package[:price] += accom_product_type.product_type.get_default_price.get_total_by_type('cost')
            package[:number_available] << InventoryEntry.find(:first, :conditions => ['product_type_id = ?' ,accom_product_type.product_type.id]).number_available
          end

          packages.delete_if{|a| a[:nights] != nights}

          #set number available
          packages.each do |package|
            package[:number_available] = package[:number_available].min
          end

          #set currency
          packages.each do |package|
            package[:price] = ActionController::Base.helpers.number_to_currency(package[:price])
          end

          packages
        end

			end
    end
  end#Mobile
end#ErpApp