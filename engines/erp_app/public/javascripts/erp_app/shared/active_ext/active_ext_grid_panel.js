Ext.ns("Compass.ErpApp.Shared.ActiveExt");

Compass.ErpApp.Shared.ActiveExt.ActiveExtGridPanel = Ext.extend(Ext.Panel, {
    setupGrid: function(){
        var self = this;
        var config = this.initialConfig;
        var modelUrlLastChar = config['modelUrl'].charAt(config['modelUrl'].length - 1);
        if(modelUrlLastChar == '/'){
            config['modelUrl'] = config['modelUrl'].substr(0, config['modelUrl'].length - 1);
        }
        var conn = new Ext.data.Connection();
        conn.request({
            url: config['modelUrl'] + '/setup',
            method: 'POST',
            params:config['params'],
            success: function(responseObject) {
                var response =  Ext.util.JSON.decode(responseObject.responseText);
                if(response.success){
                    self.add({
                        windowTitle:config['title'],
                        modelUrl:config['modelUrl'],
                        inlineEdit:response.inline_edit,
                        useExtForms:response.use_ext_forms,
                        page:config['page'],
                        editable:config['editable'],
                        pageSize:config['pageSize'],
                        displayMsg:config['displayMsg'],
                        emptyMsg:config['emptyMsg'],
                        xtype:'activeextgrid',
                        columns:response.columns,
                        fields:response.fields
                    });
                    self.getLayout().setActiveItem(0);
                }
                else{
                    var message = response.message
                    if(Compass.ErpApp.Utility.isBlank(message)){
                        message = config['loadErrorMessage']
                    }
                    Ext.Msg.alert('Error', message);
                }
            },
            failure: function() {
                Ext.Msg.alert('Error', 'Could not load grid.');
            }
        });
    },

    onRender: function() {
        Compass.ErpApp.Shared.ActiveExt.ActiveExtGridPanel.superclass.onRender.apply(this, arguments);
        this.setupGrid();
    },

    constructor : function(config) {
        config = Ext.apply({
            layout:'card'
        }, config);
        Compass.ErpApp.Shared.ActiveExt.ActiveExtGridPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('activeextgridpanel', Compass.ErpApp.Shared.ActiveExt.ActiveExtGridPanel);







