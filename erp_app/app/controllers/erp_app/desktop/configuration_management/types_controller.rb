module ErpApp
  module Desktop
    module ConfigurationManagement
      class TypesController < ::ErpApp::Desktop::BaseController

        def categories
          render :json => {:success => true,
            :categories => Category.all.collect{|category|
            category.to_hash(:methods => [{:id => :category_id}, :description])}
          }
        end

        def types_store
          render :json => {:success => true,
            :types => ConfigurationItemType.joins(:category_classification)
                      .where(:category_classifications => {:category_id => params[:category_id]}).all.collect{|type| type.to_hash(:only => [:id, :internal_identifier, :description])}
          }
        end

        def index
          item_types = [].tap do |item_types_array|
            ConfigurationItemType.all.group_by(&:category).each do |category, categorized_item_types|
              category_hash = {:text => category.description, :iconCls => 'icon-documents', :leaf => false, :children => []}
              categorized_item_types.each do |item_type|
                categorized_config_item_type_hash = {
                  :type => 'ConfigurationItemType',
                  :category_id => category.id,
                  :text => item_type.description,
                  :description => item_type.description,
                  :internal_identifier => item_type.internal_identifier,
                  :user_defined_options => item_type.allow_user_defined_options ? 'yes' : 'no',
                  :multi_optional => item_type.is_multi_optional ? 'yes' : 'no',
                  :model_id => item_type.id,
                  :iconCls => 'icon-document_info',
                  :leaf => false,
                  :children => []
                }
                if item_type.allow_user_defined_options
                  categorized_config_item_type_hash[:children] << {
                    :text => "[User Defined]",
                    :iconCls => 'icon-user',
                    :leaf => true,
                    :children => []
                  }
                else
                  #this is not dry clean up later
                  item_type.options.default.each do |option|
                    categorized_config_item_type_hash[:children] << {
                      :text => option.description,
                      :iconCls => 'icon-document_check',
                      :type => 'ConfigurationOption',
                      :model_id => option.id,
                      :type_id => item_type.id,
                      :leaf => true,
                      :children => []
                    }
                  end

                  item_type.options.non_default.each do |option|
                    categorized_config_item_type_hash[:children] << {
                      :text => option.description,
                      :iconCls => 'icon-document',
                      :type => 'ConfigurationOption',
                      :model_id => option.id,
                      :type_id => item_type.id,
                      :leaf => true,
                      :children => []
                    }
                  end
                end
                category_hash[:children] << categorized_config_item_type_hash
              end#categorized_item_types
              item_types_array << category_hash
            end#ConfigurationItemType.all
          end#tap

          render :json => item_types
        end

        def create_or_update
          type = params[:model_id].blank? ? ConfigurationItemType.new : ConfigurationItemType.find(params[:model_id])
          type.description = params[:description]
          type.internal_identifier = params[:internal_identifier]
          type.allow_user_defined_options = (params[:user_defined_options] == 'yes')
          type.is_multi_optional = (params[:multi_optional] == 'yes')
          if type.category.nil?
            CategoryClassification.create(:classification => type, :category => Category.find(params[:category_id]))
          else
            type.category_classification.category = Category.find(params[:category_id])
            type.category_classification.save
          end

          render :json => (type.save ? {:success => true} : {:success => false})
        end

        def destroy
           render :json => (ConfigurationItemType.destroy(params[:id]) ? {:success => true}: {:success => false})
        end

        def add_option
          option = ConfigurationOption.find(params[:option_id])
          type   = ConfigurationItemType.find(params[:model_id])

          if type.options.where('configuration_options.id = ?', option.id).first.nil?
            type.add_option(option)
            render :json => (type.save ? {:success => true}: {:success => false})
          else
            render :json => {:success => false, :message => 'Option already exits for Configuration Type'}
          end
        end

        def remove_option
          option = ConfigurationOption.find(params[:option_id])
          type   = ConfigurationItemType.find(params[:type_id])

          render :json => (type.remove_option(option) ? {:success => true}: {:success => false})
        end

        def set_option_as_default
          option = ConfigurationOption.find(params[:option_id])
          type = ConfigurationItemType.find(params[:type_id])

          render :json => (type.add_default_option(option) ? {:success => true}: {:success => false})
        end

      end#BaseController
    end#ConfigurationManagement
  end#Desktop
end#ErpApp