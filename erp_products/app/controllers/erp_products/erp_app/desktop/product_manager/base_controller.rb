module ErpProducts
  module ErpApp
    module Desktop
      module ProductManager
        class BaseController < ::ErpApp::Desktop::BaseController
          def index
            products = ProductType.all.collect do |product_type|
              {
                :id => product_type.id,
                :title => product_type.description,
                :imageUrl => product_type.images.empty? ? '/images/img_blank.png' : product_type.images.first.data.url(nil, :escape => false),
                :price => product_type.get_current_simple_amount_with_currency.nil? ? 'no price set' : product_type.get_current_simple_amount_with_currency,
                :available => product_type.inventory_entries.first.number_available,
                :sold => product_type.inventory_entries.first.number_sold,
                :sku => product_type.inventory_entries.first.sku.nil? ? '' : product_type.inventory_entries.first.sku
              }
            end

            render :json => {:products => products}
          end

          def show
            ProductType.class_eval do
              def long_description
                self.descriptions.find_by_internal_identifier('long_description').description
              end
            end
            product_type = ProductType.find(params[:id])
            render :json => {:id => product_type.id, :description => product_type.long_description, :title => product_type.description}
          end

          def update
            product_type = ProductType.find(params[:id])
            product_type.description = params[:title]
            descriptive_asset = product_type.find_description_by_iid('long_description')
            descriptive_asset.description = params[:description]
            descriptive_asset.save

            render :json => product_type.save ? {:success => true} : {:success => false}
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

          def delete
            render :json => (ProductType.find(params[:id]).destroy) ? {:success => true} : {:success => false}
          end

          #
          #Images
          #

          def images
            data = {:images => []}
            product_type = ProductType.find(params[:id])

            product_type.images.each do |image|
              data[:images] << {:id => image.id, :name => image.name, :shortName => image.name, :url => image.data.url}
            end

            render :json => data
          end

          def new_image
            result = {}

            begin
              name = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data].original_filename : request.env['HTTP_X_FILE_NAME']          
              data = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data] : request.raw_post

              product_type = ProductType.find(params[:product_type_id])
              #build path
              path = File.join(product_type.images_path,name)

              product_type.add_file(data, path)
              result = {:success => true}
            rescue Exception=>ex
              logger.error ex.message
              logger.error ex.backtrace.join("\n")
              result = {:success => false, :error => "Error uploading #{name}"}
            end
            
            #file uploader wants this inline
            render :inline => result.to_json
          end

          def delete_image
            render :json => (FileAsset.find(params[:id]).destroy) ? {:success => true} : {:success => false}
          end

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

        end
      end
    end
  end
end
