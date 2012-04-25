module ErpApp
  module Desktop
    module ConfigurationManagement
      class TypesController < ::ErpApp::Desktop::BaseController

        def index
          item_types = [].tap do |item_types_array|
            ConfigurationItemType.all.group_by(&:category).each do |category, categorized_item_types|
              category_hash = {:text => category.description, :iconCls => 'icon-document', :leaf => false, :children => []}
              categorized_item_types.each do |item_type|
                categorized_config_item_type_hash = {
                  :type => 'ConfigurationItemType',
                  :text => item_type.description,
                  :description => item_type.description,
                  :internal_identifier => item_type.internal_identifier,
                  :user_defined_options => item_type.allow_user_defined_options ? 'yes' : 'no',
                  :multi_optional => item_type.is_multi_optional ? 'yes' : 'no',
                  :modelId => item_type.id,
                  :iconCls => 'icon-document',
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
                  item_type.options.each do |option|
                    categorized_config_item_type_hash[:children] << {
                      :text => option.description,
                      :iconCls => 'icon-accept',
                      :type => 'ConfigurationOption',
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

      end#BaseController
    end#ConfigurationManagement
  end#Desktop
end#ErpApp