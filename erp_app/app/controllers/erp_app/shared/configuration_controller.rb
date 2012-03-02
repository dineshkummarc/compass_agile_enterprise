module ErpApp
	module Shared
		class ConfigurationController < ErpApp::ApplicationController

      def setup_categories
        configuration = ::Configuration.find(params[:id])

        render :json => {
          :success => true,
          :categories => configuration.item_types.collect{|item| item.category_classifications.first.category}.uniq.collect{|category|{:description => category.description, :id => category.id}}
        }
      end

		  def setup
        category_id = params[:category_id]
        configuration = ::Configuration.find(params[:id])

        render :json => {:success => true, :configurationItemTypes => configuration.item_types.by_category(Category.find(category_id)).collect(&:to_js_hash)}
      end

      def load
        category_id = params[:category_id]
        configuration = ::Configuration.find(params[:id])

        render :json => {:success => true, :configurationItems => configuration.items.by_category(Category.find(category_id)).collect(&:to_js_hash)}
      end

      def update
        configuration = ::Configuration.find(params[:id])

        begin
          params.each do |k,v|
             configuration.update_configuration_item(ConfigurationItemType.find_by_internal_identifier(k), v) unless (k.to_s == 'action' or k.to_s == 'controller' or k.to_s == 'id' or k.to_s == 'authenticity_token')
          end

          render :json => {:success => true, :configurationItems => configuration.items.collect(&:to_js_hash)}
        rescue Exception=>ex
          logger.error(ex.message)
          logger.error(ex.backtrace)
          render :json => {:success => false, :message => ex.message}
        end
      end

    end#ConfigurationController
  end#Shared
end#ErpApp
