Compass.ErpApp.Desktop.Applications.Scaffold.ModelsTree = Ext.extend(Ext.tree.TreePanel, {
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



