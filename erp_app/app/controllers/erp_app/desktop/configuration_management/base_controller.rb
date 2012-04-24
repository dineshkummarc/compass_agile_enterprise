module ErpApp
  module Desktop
    module ConfigurationManagement
      class BaseController < ::ErpApp::Desktop::BaseController

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
              configured_items << build_configuration_tree(config)
            end
          end

          render :json => configurations
        end

        def delete_configuration
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

        def configuration_types

        end

        def configuration_options

        end

        private

        def build_configuration_tree(config)
          config_hash = {
            :text => config.is_template ? config.description : "#{config.description}[#{config.configured_items.first.to_label}]",
            :modelId => config.id,
            :type => 'Configuration',
            :iconCls => 'icon-note',
            :leaf => false,
            :children => []
          }

          config.items.each do |config_item|
            config_item_hash = {
              :text => config_item.type.description,
              :modelId => config_item.id,
              :type => 'ConfigurationType',
              :iconCls => 'icon-document',
              :leaf => false,
              :children => []
            }

            config_item.options.each do |option|
              config_option_hash = {
                :text => option.value,
                :modelId => option.id,
                :type => 'ConfigurationOption',
                :iconCls => 'icon-accept',
                :leaf => true,
                :children => []
              }

              config_item_hash[:children] << config_option_hash
            end

            config_hash[:children] << config_item_hash
          end

          config_hash
        end

      end#BaseController
    end#ConfigurationManagement
  end#Desktop
end#ErpApp