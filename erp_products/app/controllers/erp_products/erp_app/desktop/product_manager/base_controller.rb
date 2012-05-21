module ErpProducts
  module ErpApp
    module Desktop
      module ProductManager
        class BaseController < ::ErpApp::Desktop::BaseController

          def index
            products = []
            ProductType.all.each do |product_type|
              product_hash = product_type.to_hash(
                :only => [:id, :description => :title],
                :additional_values => {
                  :imageUrl => (product_type.images.empty? ? '/images/img_blank.png' : product_type.images.first.data.url(nil, :escape => false))
                })

              #I do not like this, need to find a better way
              if product_type.respond_to?(:get_current_simple_amount_with_currency)
                product_hash[:price] = product_type.get_current_simple_amount_with_currency.nil? ? 'no price set' : product_type.get_current_simple_amount_with_currency
              end

              #I do not like this, need to find a better way
              if product_type.respond_to?(:inventory_entries)
                inventory_entry = if product_type.inventory_entries.empty?
                  InventoryEntry.create(
                    :product_type => product_type,
                    :number_available => 0,
                    :number_sold => 0,
                    :description => product_type.description
                  )
                else
                  product_type.inventory_entries.first
                end

                product_hash[:available] = inventory_entry.number_available
                product_hash[:sold] = inventory_entry.number_sold
                product_hash[:sku] = inventory_entry.sku.nil? ? '' : inventory_entry.sku
              end
              
              products << product_hash
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
              render :json => {:success => true, :id => product_type.id}
            else
              render :json => {:success => false}
            end
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


        end#BaseController
      end#ProductManager
    end#Desktop
  end#ErpApp
end#ErpProducts
