class ErpApp::Desktop::ProductManager::BaseController < ErpApp::Desktop::BaseController
  #
  #Products
  #

  def index
    products = []

    ProductType.all.each do |product_type|
      products << {
        :id => product_type.id,
        :title => product_type.description,
        :imageUrl => product_type.images.empty? ? '/images/img_blank.png' : product_type.images.first.url,
        :price => product_type.get_current_simple_amount_with_currency.nil? ? 'no price set' : product_type.get_current_simple_amount_with_currency,
        :available => product_type.inventory_entries.first.number_available,
        :sold => product_type.inventory_entries.first.number_sold,
        :sku => product_type.inventory_entries.first.sku.nil? ? '' : product_type.inventory_entries.first.sku
      }
    end

    render :inline => {:products => products}.to_json
  end

  def show
    ProductType.include_root_in_json = false

    ProductType.class_eval do
      def long_description
        self.descriptions.find_by_internal_identifier('long_description').description
      end
    end
    product_type = ProductType.find(params[:id])
    render :inline => {:id => product_type.id, :description => product_type.long_description, :title => product_type.description}.to_json
  end

  def update
    result = {}
    
    product_type = ProductType.find(params[:id])
    product_type.description = params[:title]
    descriptive_asset = product_type.find_description_by_iid('long_description')
    descriptive_asset.description = params[:description]
    descriptive_asset.save

    if product_type.save
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  def new
    result = {}

    title = params[:title]
    description = params[:description]

    product_type = ProductType.new(
      :description => title
    )

    product_type.descriptions << DescriptiveAsset.create(
      :description => description,
      :internal_identifier => 'long_description'
    )

    if product_type.save
      #create inventory
      inventory_entry = InventoryEntry.new(
        :product_type => product_type,
        :number_available => 0,
        :number_sold => 0,
        :description => product_type.description
      )
      
      if inventory_entry.save
        result[:success] = true
        result[:id] = product_type.id
      else
        product_type.destroy
        result[:success] = false
      end

    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  def delete
    result = {}

    if ProductType.find(params[:id]).destroy
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  #
  #Images
  #

  def images
    data = {:images => []}
    product_type = ProductType.find(params[:id])

    product_type.images.each do |image|
      data[:images] << {:id => image.id, :name => image.name, :shortName => image.name, :url => image.url}
    end

    render :inline => data.to_json
  end

  def new_image
    result = {}

    begin
      unless request.env['HTTP_X_FILE_NAME'].blank?
        contents = request.raw_post
        name     = request.env['HTTP_X_FILE_NAME']
      else
        file_contents = params[:file_data]
        name = file_contents.original_path
        if file_contents.respond_to?(:read)
          contents = file_contents.read
        elsif file_contents.respond_to?(:path)
          contents = File.read(file_contents.path)
        end
      end

      product_type = ProductType.find(params[:product_type_id])
      #build path
      path = File.join(product_type.images_path,name)

      product_type.add_file(path, contents)
      result = {:success => true}
    rescue Exception=>ex
      logger.error ex.message
			logger.error ex.backtrace.join("\n")
      result = {:success => false, :error => "Error uploading #{name}"}
    end

    render :inline => result.to_json
  end

  def delete_image
    result = {}

    if FileAsset.find(params[:id]).destroy
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  #
  #Prices
  #

  def currencies
    ErpBaseErpSvcs::Currency.include_root_in_json = false
    render :inline => "{currencies:#{ErpBaseErpSvcs::Currency.all.to_json(:only => [:id, :internal_identifier])}}"
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

    render :inline => result.to_json
  end


  #pricing uses one form for new models and updates. So we use one action
  def new_and_update_price
    result = {}

    if params[:pricing_plan_id].blank?
      pricing_plan = PricingPlan.new(
        :money_amount => params[:price],
        :comments => params[:comments],
        :currency => ErpBaseErpSvcs::Currency.find(params[:currency]),
        :from_date => params[:from_date].to_date,
        :thru_date => params[:thru_date].to_date,
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
      pricing_plan.currency = ErpBaseErpSvcs::Currency.find(params[:currency])
      pricing_plan.from_date = params[:from_date]
      pricing_plan.thru_date = params[:thru_date]
      pricing_plan.description = params[:description]
      pricing_plan.comments = params[:comments]

      if pricing_plan.save
        result[:success] = true
      else
        result[:success] = false
      end
    end

    render :inline => result.to_json
  end

  def delete_price
    result = {}

    if PricingPlan.find(params[:id]).destroy
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  #
  #Inventory
  #

  def inventory
    result = {}

    inventory_entry = InventoryEntry.find_by_product_type_id(params[:id])
    result[:number_available] = inventory_entry.number_available
    result[:sku] = inventory_entry.sku

    render :inline => result.to_json
  end

  def update_inventory
    result = {}

    inventory_entry = InventoryEntry.find_by_product_type_id(params[:product_type_id])
    inventory_entry.sku = params[:sku]
    inventory_entry.number_available = params[:number_available]

    if inventory_entry.save
      result[:success] = true
    else
      result[:success] = false
    end
    render :inline => result.to_json
  end

end