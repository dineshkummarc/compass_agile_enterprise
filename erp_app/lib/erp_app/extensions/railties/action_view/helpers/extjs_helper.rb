module ErpApp
  module Extensions
    module Railties
      module ActionView
        module Helpers
          module ExtjsHelper

            # example usage:
            # <%= dynamic_extjs_grid({
            #   :title => 'Accounts',
            #   :renderTo => 'grid_target',
            #   :setupUrl => build_widget_url(:accounts_grid_setup),
            #   :dataUrl => build_widget_url(:accounts_grid_data),
            #   :width => 500,
            #   :height => 200,
            #   :page => true,
            #   :pageSize => 5,
            #   :displayMsg => 'Displaying {0} - {1} of {2}',
            #   :emptyMsg => 'Empty',
            #   :storeId => "my_unique_store_id"   #this is an optional field
            # }) %>
            def dynamic_extjs_grid(options={})
              options[:title] = '' if options[:title].blank?
              options[:closable] = false if options[:closable].blank?
              options[:collapsible] = false if options[:collapsible].blank?
              options[:height] = 300 if options[:height].blank?
              
              output = raw '<script type="text/javascript">'
              output += raw "Compass.ErpApp.Utility.JsLoader.load([
                    '/javascripts/erp_app/shared/dynamic_editable_grid.js',
                    '/javascripts/erp_app/shared/dynamic_editable_grid_loader_panel.js'],
                    function(){
                      Ext.create('Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel', #{options.to_json} );
                    });"
              output += raw '</script>'

              output
            end

          end#ExtjsHelper
        end#Helpers
      end#ActionView
    end#Railties
  end#Extensions
end#ErpApp
