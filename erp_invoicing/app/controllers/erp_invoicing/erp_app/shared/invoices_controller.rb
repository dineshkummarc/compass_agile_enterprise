module ErpInvoicing
  module ErpApp
    module Shared
      class InvoicesController < ::ErpApp::Desktop::BaseController

        def parties
          render :json => {
            :parties => Party.all.collect{|party|
              {:id => party.id, :description => party.description}
            }
          }
        end

        def sms_notification
          invoice = Invoice.find(params[:id])
          if invoice.billing_account.send_sms_notification
            render :json => {:success => true}
          else
            render :json => {:success => false}
          end
        end

        def billing_accounts
          render :json => {
            :billing_accounts => BillingAccount.all.collect{|billing_account|
              {:id => billing_account.id, :account_number => billing_account.account_number}
            }
          }
        end

        def email_invoice
          invoice = Invoice.find(params[:id])
          DocumentMailer.email_document(params[:to_email], invoice.document).deliver

          render :json => {:success => true}
        end

        def print_invoice
          invoice = Invoice.find(params[:id])
          send_data(File.read(invoice.files.first.data.path), {type: 'application/pdf', disposition: 'inline'})
        end

        def invoices
          render :json => if request.put?
            #update_invoice #not implemented yet
          elsif request.get?
            get_invoices
          elsif request.delete?
            delete_invoice
          end
        end

        def get_invoices
          result = {:success => true, :invoices => [], :totalCount => 0}

          sort_hash      = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort           = sort_hash[:sort] || 'created_at'
          dir            = sort_hash[:dir] || 'DESC'
          limit          = params[:limit] || 50
          start          = params[:start] || 0

          invoices = Invoice.scoped
          invoices = invoices.where('invoice_number = ?', params[:invoice_number]) unless params[:invoice_number].blank?
          invoices = invoices.where('billing_account_id = ?', params[:billing_account_id]) unless params[:billing_account_id].blank?
          invoices = invoices.order("#{sort} #{dir}").limit(limit).offset(start)
          result[:totalCount] = invoices.count


          invoices.all.each do |invoice|
            result[:invoices] << {
              :id => invoice.id,
              :invoice_number => invoice.invoice_number,
              :description => invoice.description,
              :message => invoice.message,
              :invoice_date => invoice.invoice_date,
              :due_date => invoice.due_date,
              :billing_account => invoice.billing_account.account_number,
              :payment_due => invoice.payment_due
              #:billed_to_party => (invoice.find_parties_by_role_type('billed_to').first.description rescue ''),
              #:billed_from_party => (invoice.find_parties_by_role_type('billed_from').first.description rescue '')
            }
          end

          result
        end

        def create_invoice
          invoice_date = Date.strptime(params[:invoice_date],"%m/%d/%Y")
          due_date = Date.strptime(params[:due_date],"%m/%d/%Y")

          invoice = Invoice.new(
            :invoice_number => params[:invoice_number],
            :invoice_date => invoice_date,
            :due_date => due_date,
            :message => params[:message],
            :description => params[:description]
          )

          if invoice.save
            billing_account = BillingAccount.find(params[:billing_account_id])
            billing_account.invoices << invoice
            billing_account.save

            render :json => {:success => true}
          else

            render :json => {:success => false}
          end
        end

        def delete_invoice
          Invoice.find(params[:id]).destroy

          {:success => true}
        end

        def invoice_items
          render :json => if request.post?
            create_invoice_item
          elsif request.put?
            update_invoice_item
          elsif request.get?
            get_invoice_items
          elsif request.delete?
            delete_invoice_item
          end
        end

        def create_invoice_item
          data = params[:data]
          invoice = Invoice.find(params[:invoice_id])
          invoice_item = InvoiceItem.create(:amount => data[:amount].to_f, :quantity => data[:quantity], :item_description => data[:item_description])
          invoice.items << invoice_item

          {:success => true,
            :invoice_items => {
              :item_description => invoice_item.item_description,
              :quantity => invoice_item.quantity,
              :amount => invoice_item.amount,
              :id => invoice_item.id,
              :created_at => invoice_item.created_at
            }
          }
        end

        def update_invoice_item
          data = params[:data]
          invoice_item = InvoiceItem.find(data[:id])
          invoice_item.amount = data[:amount].to_f
          invoice_item.quantity = data[:quantity]
          invoice_item.item_description = data[:item_description]
          invoice_item.save

          {:success => true,
            :invoice_items => {
              :item_description => invoice_item.item_description,
              :quantity => invoice_item.quantity,
              :amount => invoice_item.amount,
              :id => invoice_item.id,
              :created_at => invoice_item.created_at
            }
          }
        end
      
        def get_invoice_items
          result = {:success => true, :invoice_items => [], :totalCount => 0}

          invoice = Invoice.find(params[:invoice_id])
          result[:totalCount] = invoice.items.count
          invoice.items.each do |item|
            result[:invoice_items] << {
              :item_description => item.item_description,
              :quantity => item.quantity,
              :amount => item.amount,
              :id => item.id,
              :created_at => item.created_at
            }
          end
          result
        end

        def delete_invoice_item
          InvoiceItem.find(params[:id]).destroy

          {:success => true}
        end

        def invoice_payments
          result = {:success => true, :payments => [], :totalCount => 0}

          invoice = Invoice.find(params[:invoice_id])

          invoice.payment_applications.each do |item|
            result[:payments] << {
              :payment_date => item.financial_txn.apply_date,
              :post_date => item.financial_txn.captured_payment.created_at,
              :payment_account => item.financial_txn.account.description,
              :amount => item.financial_txn.money.amount
            }
          end

          render :json => result
        end

      end#InvoicesController
    end#Shared
  end#ErpApp
end#ErpInvoicing
