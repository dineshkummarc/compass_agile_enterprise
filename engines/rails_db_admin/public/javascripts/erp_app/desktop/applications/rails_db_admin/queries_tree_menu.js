Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueriesMenuTreePanel",{
    extend:"Ext.Panel",
    alias:'widget.railsdbadmin_queriestreemenu',
    initComponent: function() {
        var self = this;
        this.store = Ext.create('Ext.data.TreeStore', {
            proxy: {
                type: 'ajax',
                url: './rails_db_admin/queries/saved_queries_tree'
            },
            root: {
                text: 'Queries',
                expanded: true,
                draggable:false,
                iconCls:'icon-content'
            }
        });

        var menuTree = new Ext.tree.TreePanel({
            store:this.store,
            animate:true,
            frame:false,
            height:650,
            border: false,
            listeners:{
                'itemclick':function(view, record, item, index, e){
                    e.stopEvent();
                    if(record.data.leaf){
                        self.initialConfig.module.displayAndExecuteQuery(record.data.id);
                    }
                },
                'itemcontextmenu':function(view, record, item, index, e){
                    e.stopEvent();
                    var contextMenu = null;
                    if(record.data.leaf){
                        contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:"Execute",
                                iconCls:'icon-settings',
                                listeners:{
                                    scope:record,
                                    'click':function(){
                                        self.initialConfig.module.displayAndExecuteQuery(record.data.id);
                                    }
                                }
                            },
                            {
                                text:"Delete",
                                iconCls:'icon-delete',
                                listeners:{
                                    scope:record,
                                    'click':function(){
                                        self.initialConfig.module.deleteQuery(record.data.id);
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
        this.items = [menuTree];
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
