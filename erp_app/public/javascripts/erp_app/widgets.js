Ext.ns("Compass.ErpApp.Widgets");

Compass.ErpApp.Widgets = {
    setup : function(uuid, name, action, params){
        var conn = new Ext.data.Connection();
        var widgetParams = {
            widget_params:Ext.encode(params)
        }
        conn.request({
            url: '/erp_app/widgets/'+name+'/'+action+'/'+uuid,
            method: 'POST',
            params:widgetParams,
            success: function(response) {
                Ext.get(uuid).dom.innerHTML = response.responseText;
                var scriptTags = Ext.get(uuid).dom.getElementsByTagName("script");
                Ext.each(scriptTags, function(scriptTag){
                    eval(scriptTag.text);
                });
            },
            failure: function(response) {
                alert('Error loading widget '+name);
            }
        });
    },

    refreshWidgets : function(){
        Ext.each(Compass.ErpApp.Widgets.LoadedWidgets, function(widget){
            Compass.ErpApp.Widgets.setup(widget.id, widget.name, widget.action, widget.params);
        });
    },

    refreshWidget : function(name, action){
        Ext.each(Compass.ErpApp.Widgets.LoadedWidgets, function(widget){
            if(widget.name == name && widget.action == action){
                Compass.ErpApp.Widgets.setup(widget.id, widget.name, widget.action, widget.params);
            }
        });
    },

    LoadedWidgets : [],

    AvailableWidgets : []
}

