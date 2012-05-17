module ErpApp
  module Desktop
    module ConfigurationManagement
      class BaseController < ::ErpApp::Desktop::BaseController

        def add_type
          configuration = ::Configuration.find(params[:configuration_id])
          type          = ConfigurationItemType.find(params[:type_id])

          render :json => if configuration.configuration_item_types << type
            {:success => true}
          else
            {:success => false}
          end
        end

        def remove_type
          configuration = ::Configuration.find(params[:configuration_id])
          type          = ConfigurationItemType.find(params[:type_id])

          render :json => if configuration.configuration_item_types.delete(type)
            {:success => true}
          else
            {:success => false}
          end
        end

        def configurations
          configurations = [].tap do |configured_items|
            ::Configuration.where('is_template = ?', false).all.each do |config|
              configured_items << build_configuration_tree(config)
            end
          end

          render :json => configurations
        end

        def configuration_templates
          configurations = [].tap do |configured_items|
            ::Configuration.templates.each do |config|
              configured_items << build_configuration_tree(config, false)
            end
          end

          render :json => configurations
        end

        def destroy
          if ::Configuration.destroy(params[:id])
            render :json => {:success => true}
          else
            render :json => {:success => false}
          end
        end

        def configuration_templates_store
          render :json => {:success => true, :templates => ::Configuration.templates.collect{|template| {:description => template.description, :id => template.id}}}
        end

        def configurable_models
          render :json => {:success => true, :models => Website.all.collect{|site| {:description => site.name, :id => site.id}}}
        end

        def create_configuration
          model = params[:type].constantize.find(params[:model])
          model.configurations.destroy_all
          configuration = ::Configuration.find(params[:template]).send(params[:configuration_action].to_sym)
          unless params[:name].blank?
            configuration.description = params[:name]
            configuration.save
          end
          model.configurations << configuration

          render :json => {:success => true}
        end

        def create_template
          if ::Configuration.create(:description => params[:name], :is_template => true, :internal_identifier => params[:name].gsub(//,'').underscore)
            render :json => {:success => true}
          else
            render :json => {:success => false}
          end
        end

        def copy_template
          template = ::Configuration.find(params[:template])
          clone    = template.clone
          clone.is_template = true
          clone.internal_identifier = params[:name].gsub(//,'').underscore
          clone.description = params[:name]

          if clone.save
            render :json => {:success => true}
          else
            render :json => {:success => false}
          end
        end

        private

        def build_configuration_tree(config, include_items=true)
          config_hash = {
            :text => config.is_template ? config.description : "#{config.description}[#{config.configured_items.first.to_label}]",
            :model_id => config.id,
            :type => 'Configuration',
            :isTemplate => config.is_template,
            :iconCls => 'icon-note',
            :leaf => false,
            :children => []
          }

          #set types
          types_hash = {:text => 'Types', :iconCls => 'icon-document_info', :leaf => false, :children => []}
          config.item_types.grouped_by_category.each do |category, config_item_type|
            category_hash = {:text => category.description, :iconCls => 'icon-documents', :leaf => false, :children => []}
            config_item_type.each do |categorized_config_item_type|
              categorized_config_item_type_hash = {:isTemplate => config.is_template, :type => 'ConfigurationType', :model_id => categorized_config_item_type.id, :configuration_id => config.id, :text => categorized_config_item_type.description, :iconCls => 'icon-document_info', :leaf => false, :children => []}
              if categorized_config_item_type.allow_user_defined_options
                categorized_config_item_type_hash[:children] << {
                  :text => "[User Defined]",
                  :iconCls => 'icon-user',
                  :leaf => true,
                  :children => []
                }
              else
                #this is not dry clean up later
                categorized_config_item_type.options.default.each do |option|
                  categorized_config_item_type_hash[:children] << {
                    :text => option.description,
                    :iconCls => 'icon-document_check',
                    :leaf => true,
                  }
                end

                categorized_config_item_type.options.non_default.each do |option|
                  categorized_config_item_type_hash[:children] << {
                    :text => option.description,
                    :iconCls => 'icon-document',
                    :leaf => true,
                    :children => []
                  }
                end
              end

              category_hash[:children] << categorized_config_item_type_hash
            end
            types_hash[:children] << category_hash
          end
          config_hash[:children] << types_hash

          if include_items
            #set items
            items_hash = {:text => 'Items', :iconCls => 'icon-document_info', :leaf => false, :children => []}
            config.items.grouped_by_category.each do |category, config_item|
              category_hash = {:text => category.description, :iconCls => 'icon-documents', :leaf => false, :children => []}
              config_item.each do |categorized_config_item|
                categorized_config_item_hash = {:text => categorized_config_item.type.description, :iconCls => 'icon-document_info', :leaf => false, :children => []}
                categorized_config_item.options.each do |option|
                  categorized_config_item_hash[:children] << {
                    :text => categorized_config_item.type.allow_user_defined_options ? option.value : option.description,
                    :iconCls => 'icon-document_check',
                    :leaf => true,
                    :children => []
                  }
                end

                category_hash[:children] << categorized_config_item_hash
              end
              items_hash[:children] << category_hash
            end
            config_hash[:children] << items_hash
          end

          config_hash
        end

      end#BaseController
    end#ConfigurationManagement
  end#Desktop
end#ErpApp