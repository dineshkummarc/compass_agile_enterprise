Compass.RailsDbAdmin.TablesMenuTreePanel = Ext.extend(Compass.ErpApp.Organizer.DefaultMenuTreePanel, {
    
    constructor : function(config) {
        
        var treeConfig = {
            loader:{
                dataUrl:'./base/tables',
                timeout:65000,
                baseParams:{
                    "database":null
                }
            },
            listeners:{
                'contextmenu':function(node, e){
                    if(node.parentNode == null || node.parentNode.parentNode != null){
                        return false;
                    }
                    else{
                        contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:"Select Top 50",
                                iconCls:'icon-settings',
                                listeners:{
                                    scope:node,
                                    'click':function(){
                                        window.RailsDbAdmin.selectTopFifty(this.id);
                                    }
                                }
                            },
                            {
                                text:"Edit Table Data",
                                iconCls:'icon-edit',
                                listeners:{
                                    scope:node,
                                    'click':function(){
                                        window.RailsDbAdmin.getTableData(this.id);
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
            title:'Tables',
            autoScroll:true,
            menuRootIconCls:'icon-content',
            rootNodeTitle:'Tables',
            treeConfig:treeConfig
        }, config);
        Compass.RailsDbAdmin.TablesMenuTreePanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('tablestreemenu', Compass.RailsDbAdmin.TablesMenuTreePanel);
