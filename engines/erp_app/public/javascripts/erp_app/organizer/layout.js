Ext.ns("Compass.ErpApp.Organizer.Applications");

Compass.ErpApp.Organizer.Layout = function(config){
   
    this.layoutConfig = config;

    //used to build accordion menu
    var accordionMenuItems = []

    var menu = Ext.create('Ext.menu.Menu', {
        items:[
        {
            text: 'Preferences',
            iconCls:'icon-gear',
            handler: function(){
                var win = Ext.create("Compass.ErpApp.Organizer.PreferencesWindow",{});
                win.show();
                win.setup();
            }
        }]
    });

    var toolbar = Ext.create("Ext.toolbar.Toolbar",{
        items: [
        {
            text:'Menu',
            iconCls:'icon-info',
            menu:menu
        }]
    });

    this.ToolBar = toolbar;

    this.addToToolBar = function(item){
        toolbar.add("|");
        toolbar.add(item);
    };

    this.setupLogoutButton = function(){
        toolbar.add("->");
        toolbar.add({
            text: 'Logout',
            xtype:'button',
            iconCls:"icon-exit",
            defaultAlign : "right",
            'listeners': {
                scope:this,
                'click':function() {
                    var defaultLogoutUrl = Compass.ErpApp.Utility.getRootUrl() + 'erp_app/logout';
                    if(Compass.ErpApp.Utility.isBlank(this.layoutConfig) || Compass.ErpApp.Utility.isBlank(this.layoutConfig["logout_url"])){
                        window.location = defaultLogoutUrl;
                    }
                    else{
                        window.location = this.layoutConfig["logout_url"];
                    }
                    
                }
            }
        });
    };

    this.CenterPanel = Ext.create("Ext.Panel",{
        id:'erp_app_viewport_center',
        region : 'center',
        margins : '0 0 0 0',
        layout: 'card',
        activeItem : 0,
        minsize : 300,
        items : []
    });

    this.NorthPanel = Ext.create("Ext.Panel",{
        region : 'north',
        height:29,
        layout: 'anchor',
        margins : '0 0 0 0',
        cmargins : '0 0 0 0',
        items:[
        toolbar
        ]
    });

    this.EastPanel = Ext.create("Ext.Panel",{
        region : 'east',
        hidden : true
    });

    var southToolbar = Ext.create("Ext.toolbar.Toolbar",{
        items:[
        {
            xtype:'tbtext',
            html:"Version 1.0"
        },
        "->",
        {
            xtype:"trayclock"
        }
        ]
    });

    this.SouthToolBar = southToolbar;

    this.SouthPanel = Ext.create("Ext.Panel",{
        region : 'south',
        height:29,
        layout: 'anchor',
        margins : '0 0 0 0',
        cmargins : '0 0 0 0',
        items:[
        southToolbar
        ]
    });

    this.addApplication = function(menuPanel, components){
        accordionMenuItems.push(menuPanel);
        for(var i=0; i < components.length; i++){
            this.CenterPanel.add(components[i]);
        }
    };

    this.setup = function(){
        this.WestPanel = Ext.create("Ext.Panel",{
            region : 'west',
            margins : '0 0 0 0',
            cmargins : '0 0 0 0',
            width : 300,
            collapsible: true,
            layout: 'accordion',
            items:accordionMenuItems
        });

        this.viewPort = Ext.create('Ext.container.Viewport', {
            layout : 'border',
            border : false,
            items :
            [
            this.NorthPanel,
            this.WestPanel,
            this.CenterPanel,
            this.EastPanel,
            this.SouthPanel
            ]
        });
    };
};

Compass.ErpApp.Organizer.Layout.setActiveCenterItem = function(id, loadRemoteData){
    Ext.ComponentMgr.get('erp_app_viewport_center').layout.setActiveItem(id);
    var activeItem = Ext.ComponentMgr.get(id);
    
    if ( loadRemoteData === undefined || loadRemoteData ) {
        var hasLoad = ( (typeof activeItem.loadRemoteData) != 'undefined' );

        if(hasLoad){
            activeItem.loadRemoteData();
        }
    }

};



