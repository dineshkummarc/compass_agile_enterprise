Ext.ns("Compass.ErpApp.Widgets");

Compass.ErpApp.Widgets = {
  setup : function(uuid, name, action, params, addToLoaded){
    var widgetParams = {
      widget_params:Ext.encode(params)
    }
    Ext.Ajax.request({
      url: '/erp_app/widgets/'+name+'/'+action+'/'+uuid,
      method: 'POST',
      params:widgetParams,
      success: function(response) {
        Ext.get(uuid).dom.innerHTML = response.responseText;
        Compass.ErpApp.Utility.evaluateScriptTags(Ext.get(uuid).dom);
        Compass.ErpApp.JQuerySpport.setupHtmlReplace();
        if(addToLoaded)
          Compass.ErpApp.Widgets.LoadedWidgets.push({
            id:uuid,
            name:name,
            action:action,
            params:params
          });
      },
      failure: function(response) {
        alert('Error loading widget '+name);
      }
    });
  },

  refreshWidgets : function(){
    Ext.each(Compass.ErpApp.Widgets.LoadedWidgets, function(widget){
      Compass.ErpApp.Widgets.setup(widget.id, widget.name, widget.action, widget.params, false);
    });
  },

  refreshWidget : function(name, action){
    Ext.each(Compass.ErpApp.Widgets.LoadedWidgets, function(widget){
      if(widget.name == name && widget.action == action){
        Compass.ErpApp.Widgets.setup(widget.id, widget.name, widget.action, widget.params, false);
      }
    });
  },

  LoadedWidgets : [],

  AvailableWidgets : []
}

