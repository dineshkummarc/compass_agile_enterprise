Ext.define("Compass.ErpApp.Desktop.Applications.Scaffold.ModelsTree",{
    extend:"Ext.tree.Panel",
    alias:'widget.scaffold_modelstreepanel',
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
                        var obj =  Ext.decode(response.responseText);
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
                        var obj = Ext.decode(response.responseText);
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

    constructor : function(config) {
        var self = this;

        var store = Ext.create('Ext.data.TreeStore', {
            proxy: {
                type: 'ajax',
                url: './scaffold/get_active_ext_models'
            },
            root: {
                text: 'Models',
                draggable:false
            },
            fields:[
                {name:'text'},
                {name:'iconCls'},
                {name:'model'},
                {name:'leaf'}
            ]
        });

        config = Ext.apply({
            store:store,
            animate:false,
            region:'west',
            autoScroll:true,
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
                'itemclick':function(view, record){
                    if(record.data.leaf){
                        self.initialConfig.scaffold.loadModel(record.data.model);
                    }
                },
                'contextmenu':function(node, e){
                    e.stopEvent();
                }
            }
        }, config);

        this.callParent([config]);
    }
});



