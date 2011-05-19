Ext.ns("Compass.ErpApp.Widgets");

Compass.ErpApp.Widgets = {
    setup : function(id, name, view, params){
        var conn = new Ext.data.Connection();
        conn.request({
            url: '/widgets/'+name+'/'+view,
            method: 'POST',
            params:params,
            success: function(response) {
                Ext.get(id).dom.innerHTML = response.responseText;
            },
            failure: function(response) {
                alert('Error loading widget '+name);
            }
        });
    },

    AvailableWidgets : []
}

