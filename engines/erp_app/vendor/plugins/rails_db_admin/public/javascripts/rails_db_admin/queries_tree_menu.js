Compass.RailsDbAdmin.QueriesMenuTreePanel = Ext.extend(Compass.ErpApp.Organizer.DefaultMenuTreePanel, {
    
    constructor : function(config) {
        
        var treeConfig = {
            loader:{
                dataUrl:'./queries/saved_queries_tree',
                timeout:65000,
                baseParams:{
                    "database":null
                }
            },
            listeners:{
                'contextmenu':function(node, e){
                    if(node.isLeaf()){
                        var contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:"Execute",
                                iconCls:'icon-settings',
                                listeners:{
                                    scope:node,
                                    'click':function(){
                                        window.RailsDbAdmin.displayAndExecuteQuery(this.id);
                                    }
                                }
                            },
                            {
                                text:"Delete",
                                iconCls:'icon-delete',
                                listeners:{
                                    scope:node,
                                    'click':function(){
                                        window.RailsDbAdmin.deleteQuery(this.id);
                                    }
                                }
                            }
                            ]
                        });
                        contextMenu.showAt(e.xy);
                    }
                    else{
                        var contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:"New Query",
                                iconCls:'icon-new',
                                listeners:{
                                    'click':function(){
                                        window.RailsDbAdmin.addNewQueryTab();
                                    }
                                }
                            }
                            ]
                        });
                        contextMenu.showAt(e.xy);
                    }
                }
            }
        }

        config = Ext.apply({
            title:'Queries',
            autoScroll:true,
            menuRootIconCls:'icon-content',
            rootNodeTitle:'Queries',
            treeConfig:treeConfig
        }, config);
        Compass.RailsDbAdmin.QueriesMenuTreePanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('queriestreemenu', Compass.RailsDbAdmin.QueriesMenuTreePanel);
