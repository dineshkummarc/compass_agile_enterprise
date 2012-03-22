module ErpApp::ExtjsHelper

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

end
