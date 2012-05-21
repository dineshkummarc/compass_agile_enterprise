ErpProducts::ErpApp::Desktop::ProductManager::BaseController.class_eval do

  #
  #Prices
  #

  def currencies
    Currency.include_root_in_json = false
    render :inline => "{currencies:#{Currency.all.to_json(:only => [:id, :internal_identifier])}}"
  end

  def prices
    result = {:prices => []}

    product_type = ProductType.find(params[:id])
    product_type.pricing_plans.each do |pricing_plan|
      result[:prices] << {
        :pricing_plan_id => pricing_plan.id,
        :price => pricing_plan.money_amount,
        :currency => pricing_plan.currency.id,
        :currency_display => pricing_plan.currency.internal_identifier,
        :from_date => pricing_plan.from_date,
        :thru_date => pricing_plan.thru_date,
        :description => pricing_plan.description,
        :comments => pricing_plan.comments
      }
    end

    render :json => result
  end


  #pricing uses one form for new models and updates. So we use one action
  def new_and_update_price
    result = {}

    if params[:pricing_plan_id].blank?
      pricing_plan = PricingPlan.new(
        :money_amount => params[:price],
        :comments => params[:comments],
        :currency => Currency.find(params[:currency]),
        :from_date => Date.strptime(params[:from_date], '%m/%d/%Y').to_date,
        :thru_date => Date.strptime(params[:thru_date], '%m/%d/%Y').to_date,
        :description => params[:description],
        :is_simple_amount => true
      )

      if pricing_plan.save
        product_type = ProductType.find(params[:product_type_id])
        product_type.pricing_plans << pricing_plan
        if product_type.save
          result[:success] = true
        else
          pricing_plan.destroy
          result[:success] = false
        end
      else
        result[:success] = false
      end
    else
      pricing_plan = PricingPlan.find(params[:pricing_plan_id])
      pricing_plan.money_amount = params[:price]
      pricing_plan.currency = Currency.find(params[:currency])
      pricing_plan.from_date = Date.strptime(params[:from_date], '%m/%d/%Y').to_date
      pricing_plan.thru_date = Date.strptime(params[:thru_date], '%m/%d/%Y').to_date
      pricing_plan.description = params[:description]
      pricing_plan.comments = params[:comments]

      if pricing_plan.save
        result[:success] = true
      else
        result[:success] = false
      end
    end

    render :json => result
  end

  def delete_price
    render :json => (PricingPlan.find(params[:id]).destroy) ? {:success => true} : {:success => false}
  end
  
end
