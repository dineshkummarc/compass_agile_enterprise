ErpProducts::ErpApp::Desktop::ProductManager::BaseController.class_eval do

  #
  #Inventory
  #

  def inventory
    result = {}

    inventory_entry = InventoryEntry.find_by_product_type_id(params[:id])
    result[:number_available] = inventory_entry.number_available
    result[:sku] = inventory_entry.sku

    render :json => result
  end

  def update_inventory
    inventory_entry = InventoryEntry.find_by_product_type_id(params[:product_type_id])
    inventory_entry.sku = params[:sku]
    inventory_entry.number_available = params[:number_available]

    render :json => (inventory_entry.save) ? {:success => true} : {:success => false}
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

    render :json => result
  end
  
end
