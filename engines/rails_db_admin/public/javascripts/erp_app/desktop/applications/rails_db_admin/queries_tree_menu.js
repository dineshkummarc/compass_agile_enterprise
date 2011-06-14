Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueriesMenuTreePanel = Ext.extend(Ext.Panel, {
    initComponent: function() {
        var self = this;
        var menuRoot = new Ext.tree.AsyncTreeNode({
            text: 'Queries',
            draggable:false,
            iconCls:'icon-content'
        });

        var menuTree = new Ext.tree.TreePanel({
            animate:true,
            autoScroll:false,
            frame:true,
            autoLoad : false,
            enableDD:false,
            containerScroll: true,
            border: false,
            width: "auto",
            height: "auto",
            loader:{
                dataUrl:'./rails_db_admin/queries/saved_queries_tree',
                timeout:65000,
                baseParams:{
                    "database":null
                }
            },
            listeners:{
                'contextmenu':function(node, e){
                    e.stopEvent();
                    var contextMenu = null;
                    if(node.isLeaf()){
                        contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:"Execute",
                                iconCls:'icon-settings',
                                listeners:{
                                    scope:node,
                                    'click':function(){
                                        self.initialConfig.module.displayAndExecuteQuery(this.id);
                                    }
                                }
                            },
                            {
                                text:"Delete",
                                iconCls:'icon-delete',
                                listeners:{
                                    scope:node,
                                    'click':function(){
                                        self.initialConfig.module.deleteQuery(this.id);
                                    }
                                }
                            }
                            ]
                        });
                    }
                    else{
                        contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:"New Query",
                                iconCls:'icon-new',
                                listeners:{
                                    'click':function(){
                                        self.initialConfig.module.addNewQueryTab();
                                    }
                                }
                            }
                            ]
                        });
                    }
                    contextMenu.showAt(e.xy);
                }
            }
        });

        this.treePanel = menuTree;
        menuTree.setRootNode(menuRoot);
        this.items = [menuTree];
        menuRoot.expand();
        Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueriesMenuTreePanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        config = Ext.apply({
            title:'Queries',
            autoScroll:true
        }, config);
        Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueriesMenuTreePanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('railsdbadmin_queriestreemenu', Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueriesMenuTreePanel);
