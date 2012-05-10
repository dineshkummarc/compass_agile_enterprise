module ErpInvoicing
  class SmsController < ::ActionController::Base
    before_filter :allow_by_ip

    # Receive SMS callback from clickatell
    # Example: If you provide this URL http://www.yourdomain.com/erp_invoicing/sms/receive_response then we will do a POST or GET as follows:
    # https://www.yourdomain.com/sms/receive_response?api_id=12345&from=279991235642&to=27123456789&
    # timestamp=2008-08-0609:43:50&text=Hereisthe%20messagetext&charset=ISO-8859-1&udh=&moMsgId=b2aee337abd962489b123fda9c3480fa
    def receive_response
      message_text = params[:text]
      moMsgId = params[:moMsgId]
      to_number = params[:to]
      from_number = params[:from]

      if message_text.blank? or to_number.blank? or from_number.blank?
        Rails.logger.error 'ErpInvoicing::SmsController#receive_response called with insufficient data'
        render_false and return
        render :json => {:success => false} and return
      end

      # find the comm event sent within past 10mins where that incoming message is a reponse to
      cmm_evt = CommunicationEvent.find_by_sql("SELECT * FROM communication_events
                                    JOIN phone_numbers from_phone ON from_contact_mechanism_id=from_phone.id
                                    JOIN phone_numbers to_phone ON to_contact_mechanism_id=to_phone.id
                                    WHERE from_contact_mechanism_type = 'PhoneNumber' 
                                    AND from_contact_mechanism_type='PhoneNumber'
                                    AND from_phone.phone_number = '#{to_number.to_s}'
                                    AND (to_phone.phone_number = '#{from_number.to_s}' OR to_phone.phone_number = '#{from_number[1..from_number.length]}')
                                    AND communication_events.created_at > '#{SMS_TIME_WINDOW.minutes.ago.to_s}'
                                    ORDER BY communication_events.created_at DESC").first

      unless cmm_evt.nil?
        if message_text.downcase.include?('yespay') or message_text.downcase.include?('yes pay')
          billing_account = BillingAccount.find(cmm_evt.case_id)
          payment_due = billing_account.payment_due

          # TODO: scrape for amount and compare with payment_due on account?

          if billing_account.has_outstanding_balance?
            success = submit_payment(cmm_evt, billing_account) if billing_account.has_outstanding_balance?
          else
            Rails.logger.error 'ErpInvoicing::SmsController#receive_response called: skipping payment NO OUTSTANDING BALANCE TO PAY'
          end
          to_party = cmm_evt.from_party

          # log communication event
          new_cmm_evt = CommunicationEvent.new
          new_cmm_evt.short_description = 'SMS Response'
          new_cmm_evt.comm_evt_purpose_types << CommEvtPurposeType.find_by_internal_identifier('sms_response')
          new_cmm_evt.to_role = RoleType.find_by_internal_identifier('application')
          new_cmm_evt.to_party = to_party
          new_cmm_evt.to_contact_mechanism = to_party.default_phone_number
          new_cmm_evt.from_contact_mechanism = cmm_evt.to_party.billing_phone_number
          new_cmm_evt.from_role = RoleType.find_by_internal_identifier('customer')
          new_cmm_evt.from_party = cmm_evt.to_party
          new_cmm_evt.case_id = cmm_evt.case_id
          new_cmm_evt.notes = "From Number: #{from_number}, To Number: #{to_number}, Message: #{message_text}, Payment: #{success}"
          new_cmm_evt.external_identifier = moMsgId
          new_cmm_evt.save

          if success
            # send successful payment notification
            clikatell = ErpTechSvcs::SmsWrapper::Clickatell.new
            clikatell.send_message(from_number, SMS_SUCCESS_NOTIFICATION.gsub('payment_due', payment_due.to_s), :mo => 1, :from => to_number)
            render_true and return
          else
            render_false and return
          end
        end
      else
        Rails.logger.error "ErpInvoicing::SmsController#receive_  ation event #{moMsgId}"
        render :json => {:success => false} and return
      end
    end

    protected
    def submit_payment(cmm_evt, billing_account)
      party = cmm_evt.to_party

      @error_message = nil
      @message = nil
      @payment_accounts = party.payment_accounts

      root_account = BizTxnAcctRoot.find(@payment_accounts.first)
      @payment_account = root_account.account
      @amount = billing_account.payment_due
      @payment_date = Date.today
      
      money = Money.create(
        :amount => @amount.to_f,
        :description => "Clicktopay Payment Applied",
        :currency => Currency.usd
      )
      financial_txn = FinancialTxn.new(:apply_date => @payment_date)
      financial_txn.description = "Clicktopay Payment Applied"
      financial_txn.money = money
      financial_txn.account = root_account
      financial_txn.save
      
      PaymentApplication.create(
        :financial_txn => financial_txn,
        :payment_applied_to => billing_account,
        :money => money
      )

      if financial_txn.apply_date == Date.today
        case @payment_account.class.to_s
        when "BankAccount"
          financial_txn.txn_type = BizTxnType.ach_sale
          financial_txn.save
          result = @payment_account.purchase(financial_txn, ErpCommerce::Config.active_merchant_gateway_wrapper)
          if !result[:payment].nil? and result[:payment].success
            @authorization_code = result[:payment].authorization_code
          else
            @message = result[:message]
          end
        when "CreditCardAccount"
          financial_txn.txn_type = BizTxnType.cc_sale
          financial_txn.save
          result = @payment_account.purchase(financial_txn, '123', ErpCommerce::Config.active_merchant_gateway_wrapper)
          if !result[:payment].nil? and result[:payment].success
            @authorization_code = result[:payment].authorization_code
          else
            @message = result[:message]
          end
        end
      end

      if @error_message.nil?
        Rails.logger.info 'ErpInvoicing::SmsController#submit_payment called: payment successful'
      else
        Rails.logger.error 'ErpInvoicing::SmsController#submit_payment called: payment failed'
      end
    end


    def render_false
      render :json => {:success => false}
    end

    def render_true
      render :json => {:success => true}
    end

    def allow_by_ip
      Rails.logger.info "ErpInvoicing::SmsController#allow_by_ip called: request from #{request.remote_ip}"
      if request.remote_ip != SMS_SERVICE_IP
        redirect_to '/'
        flash.now[:notice] = "Access denied!"
        return false
      end
    end


  end
end
