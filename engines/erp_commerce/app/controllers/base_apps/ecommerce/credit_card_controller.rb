class BaseApps::Ecommerce::CreditCardController < ApplicationController
  
  require 'builder'

  before_filter :login_required  
  before_filter :get_credit_card_info
  
  def get_credit_card_info
    card_number  = params[:card_number]
    exp_month    = params[:exp_month]
    exp_year     = params[:exp_year]
    cvvs         = params[:cvvs]
    amount       = params[:amount]
    name_on_card = params[:name_on_card]
    card_type    = params[:card_type]

    params = {}
    params[:amount] = amount
    params[:credit_card] = {}
    params[:credit_card][:number] = card_number
    params[:credit_card][:exp_month] = exp_month
    params[:credit_card][:exp_year] = exp_year
    params[:credit_card][:type] = card_type
    params[:credit_card][:cvvs] = cvvs
    params[:credit_card][:name_on_card] = name_on_card
    
    @credit_card_params = params
  end
  
  def show
    
    respond_to do |format|
            
      token = params[:credit_card_token]
      card = CreditCard.find_by_credit_card_token(token)
      xml = build_card_xml( card )

      format.html
      format.xml  { render :xml => xml }
      
    end    
    
  end

  # GET /credit_cards/new
  # GET /credit_cards/new.xml
  def new
    @credit_card = CreditCard.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @credit_card.credit_card_token }
    end
  end

  # POST /credit_cards
  # POST /credit_cards.xml
  def create
    
    cc = CreditCard.find_by_private_card_number( params[:credit_card][:card_number] )
    if cc
      # puts "I found a credit card with that exact info"
      # puts cc.to_yaml
      # puts '----'
      # puts 'redirecting to show action with token:' + cc.credit_card_token
      render :xml => build_card_xml( cc )
  
    else
    
      @credit_card = CreditCard.new(params[:credit_card])
    
      respond_to do |format|
   
          if @credit_card.save
            
            xml = build_token_xml( @credit_card )
            
            format.html { redirect_to(@credit_card, :notice => 'CreditCard was successfully created.') }
            format.xml  { render :xml => xml, :status => :created, :location => @credit_card }
            
          else
            format.html { render :action => "new" }
            format.xml  { 
              render :xml => @credit_card.errors, 
              :status => :unprocessable_entity 
              }
          end
   
      end
    end

  end

  def build_token_xml( credit_card )
    xml = Builder::XmlMarkup.new( :target => '', :indent => 2 )
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml.credit_card {   
      xml.credit_card_token( credit_card.credit_card_token )
    }
  end

  def build_card_xml( credit_card )
    xml = Builder::XmlMarkup.new( :target => '', :indent => 2 )
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml.credit_card { 
      xml.card_description( credit_card.description)  
      xml.credit_card_token( credit_card.credit_card_token )
      xml.private_card_number( credit_card.private_card_number )      
    }
  end

  def build_card_xml_from_token( token )

    card = CreditCard.find_by_credit_card_token(token)
    xml = build_card_xml( card )
    return card_data
    
  end
   
end