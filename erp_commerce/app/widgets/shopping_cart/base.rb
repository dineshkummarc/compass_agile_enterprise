module Widgets
  module ShoppingCart
    class Base < ErpApp::Widgets::Base
      class Helper
        include Singleton
        include ActionView::Helpers::NumberHelper
      end

      def help
        Helper.instance
      end

      def price_summary
        @item_count = 0
        @cart_items_url = params[:cart_items_url]

        #if we have an order started get all charges
        order = ErpApp::Widget::ShoppingCart::Helpers::Order.new(self).get_order
        @item_count = order.line_items.count unless order.nil?
        set_total_price(order)

        render
      end

      def cart_items
        @price = 0
        @products_url = params[:products_url]
        @order = ErpApp::Widget::ShoppingCart::Helpers::Order.new(self).get_order(true)
        set_total_price(@order)

        render
      end

      def remove_from_cart
        @products_url = params[:products_url]
        @order = ErpApp::Widget::ShoppingCart::Helpers::Order.new(self).remove_from_cart(params[:id])
        set_total_price(@order)

        render :view => :cart_items
      end

      def checkout_demographics
        if self.authenticated?
          params[:ship_to_billing] = 'on'
          params[:bill_to_email] = current_user.email
          @products_url = params[:products_url]
          @order = ErpApp::Widget::ShoppingCart::Helpers::Order.new(self).get_order
          set_total_price(@order)

          render :view => :demographics
        else
          render :view => :login
        end
      end

      def checkout_payment
        @products_url = params[:products_url]
        @order = ErpApp::Widget::ShoppingCart::Helpers::Order.new(self).get_order
        set_total_price(@order)

        messages = validate_demographics
        unless messages.empty?

          @billing_error_message = '<ul>'
          messages.select{|item| item =~ /^B/}.collect{|item| "<li>#{item}</li>"}.each do |html| @billing_error_message << html end
          @billing_error_message << '</ul>'

          @shipping_error_message = '<ul>'
          messages.select{|item| item =~ /^S/}.collect{|item| "<li>#{item}</li>"}.each do |html| @shipping_error_message << html end
          @shipping_error_message << '</ul>'

          render :view => :demographics
        else
          @order = ErpApp::Widget::ShoppingCart::Helpers::Order.new(self).set_demographic_info(params)

          render :view => :payment
        end
      end

      def checkout_finalize
        @products_url = params[:products_url]
        success, @message, @order = ErpApp::Widget::ShoppingCart::Helpers::Order.new(self).complete_order(params)
        set_total_price(@order)

        if success
          render :view => :confirmation
        else
          render :view => :payment
        end
      end

      private

      def set_total_price(order)
        @price = 0

        #if we have an order started get all charges
        unless order.nil?
          order.get_total_charges.each do |money|
            @price += money.amount
          end
        end

        #format it
        @price = help.number_to_currency(@price)
      end

      def validate_demographics
        messages = []

        fields = [
          {:param => '_to_first_name', :name => 'First Name'},
          {:param => '_to_last_name', :name => 'Last Name'},
          {:param => '_to_address_line_1', :name => 'Address Line 1'},
          {:param => '_to_city', :name => 'City'},
          {:param => '_to_state', :name => 'State'},
          {:param => '_to_postal_code', :name => 'Postal Code'},
          {:param => '_to_country', :name => 'Country'},
          {:param => '_to_phone', :name => 'Phone'},
          {:param => '_to_email', :name => 'Email'}
        ]

        #check billing fields
        fields.each do |field|
          param = ('bill'+field[:param]).to_sym
          if params[param].blank?
            messages << "Billing #{field[:name]} is required."
          end
        end

        #check if shipping is different than billing
        unless params[:ship_to_billing] == 'on'
          #check shipping fields
          fields.each do |field|
            next if (field[:param] == '_to_phone' or field[:param] == '_to_email')
            param = ('ship'+field[:param]).to_sym
            if params[param].blank?
              messages << "Shipping #{field[:name]} is required."
            end
          end
        end

        messages
      end

      #should not be modified
      #modify at your own risk
      self.view_paths = File.join(File.dirname(__FILE__),"/views")

      def locate
        File.dirname(__FILE__)
      end

      class << self
        def title
          "Shopping Cart"
        end

        def widget_name
          File.basename(File.dirname(__FILE__))
        end

        def base_layout
          begin
            file = File.join(File.dirname(__FILE__),"/views/layouts/base.html.erb")
            IO.read(file)
          rescue
            return nil
          end
        end
      end

    end#Base
  end#ShoppingCart
end#Widgets