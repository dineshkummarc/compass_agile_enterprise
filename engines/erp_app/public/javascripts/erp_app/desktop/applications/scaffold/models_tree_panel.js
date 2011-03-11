Compass.ErpApp.Desktop.Applications.Scaffold.ModelsTree = Ext.extend(Ext.tree.TreePanel, {
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    addModel : function(){
        var self = this;
        Ext.MessageBox.prompt('Add Model', 'Model name:', function(btn, text){
            if(btn == 'ok'){
                self.setWindowStatus('Adding model to scaffold');
                var conn = new Ext.data.Connection();
                conn.request({
                    url:'./scaffold/create_model',
                    method: 'POST',
                    params:{
                        name:text
                    },
                    success: function(response) {
                        self.clearWindowStatus();
                        var obj =  Ext.util.JSON.decode(response.responseText);
                        if(obj.success){
                            Ext.MessageBox.confirm('Confirm', 'Page must reload for changes to take affect. Reload now?', function(btn){
                                if(btn == 'no'){
                                    return false;
                                }
                                else{
                                    window.location.reload();
                                }
                            });
                        }
                        else{
                            Ext.Msg.alert("Error", obj.msg);
                        }
                    },
                    failure: function(response) {
                        self.clearWindowStatus();
                        var obj =  Ext.util.JSON.decode(response.responseText);
                        if(!Compass.ErpApp.Utility.isBlank(obj) && !Compass.ErpApp.Utility.isBlank(obj.msg)){
                            Ext.Msg.alert("Error", obj.msg);
                        }
                        else{
                            Ext.Msg.alert("Error", "Error adding model");
                        }
                    }
                });
            }
        });
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Scaffold.ModelsTree.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var self = this;
        config = Ext.apply({
            animate:false,
            region:'west',
            autoScroll:true,
            loader: new Ext.tree.TreeLoader({
                dataUrl:'./scaffold/get_active_ext_models'
            }),
            root:new Ext.tree.AsyncTreeNode({
                text: 'Models',
                draggable:false
            }),
            tbar:{
                items:[
                {
                    text:'Add Model',
                    iconCls:'icon-add',
                    scope:this,
                    handler:function(){
                        this.addModel();
                    }
                }
                ]
            },
            enableDD:true,
            containerScroll: true,
            border: false,
            frame:true,
            width: 250,
            height: 300,
            listeners:{
                'contextmenu':function(node, e){
                    e.stopEvent();
                    var contextMenu = new Ext.menu.Menu({
                        items:[
                        {
                            text:'View',
                            iconCls:'icon-search',
                            handler:function(btn){
                                self.initialConfig.scaffold.loadModel(node.id);
                            }
                        }
                        ]
                    });
                    contextMenu.showAt(e.xy);
                }
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.Scaffold.ModelsTree.superclass.constructor.call(this, config);
    }
});

Ext.reg('scaffold_modelstreepanel', Compass.ErpApp.Desktop.Applications.Scaffold.ModelsTree);



