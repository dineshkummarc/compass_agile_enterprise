Compass.ErpApp.Desktop.Applications.RailsDbAdmin.TablesMenuTreePanel = Ext.extend(Ext.Panel, {
    initComponent: function() {
        var self = this;
        var menuRoot = new Ext.tree.AsyncTreeNode({
            text: 'Tables',
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
                dataUrl:'./rails_db_admin/base/tables',
                timeout:65000,
                baseParams:{
                    "database":null
                }
            },
            listeners:{
                'contextmenu':function(node, e){
                    e.stopEvent();
                    if(node.parentNode == null || node.parentNode.parentNode != null){
                        return false;
                    }
                    else{
                        var contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:"Select Top 50",
                                iconCls:'icon-settings',
                                listeners:{
                                    scope:node,
                                    'click':function(){
                                        self.initialConfig.module.selectTopFifty(this.id);
                                    }
                                }
                            },
                            {
                                text:"Edit Table Data",
                                iconCls:'icon-edit',
                                listeners:{
                                    scope:node,
                                    'click':function(){
                                        self.initialConfig.module.getTableData(this.id);
                                    }
                                }
                            }
                            ]
                        });
                        contextMenu.showAt(e.xy);
                    }
                }
            }
        });

        this.treePanel = menuTree;
        menuTree.setRootNode(menuRoot);
        this.items = [menuTree];
        menuRoot.expand();
        Compass.ErpApp.Desktop.Applications.RailsDbAdmin.TablesMenuTreePanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        config = Ext.apply({
            title:'Tables',
            autoScroll:true
        }, config);
        Compass.ErpApp.Desktop.Applications.RailsDbAdmin.TablesMenuTreePanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('railsdbadmin_tablestreemenu', Compass.ErpApp.Desktop.Applications.RailsDbAdmin.TablesMenuTreePanel);
