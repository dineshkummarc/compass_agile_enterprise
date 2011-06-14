Ext.ns("Compass.ErpApp.Organizer");
Ext.ns("Compass.ErpApp.Organizer.Applications");

Compass.ErpApp.Organizer.Layout = function(config){
   
    this.layoutConfig = config;

    //used to build accordion menu
    var accordionMenuItems = []

    var toolbar =  new Ext.Toolbar({
        items: []
    });

    this.ToolBar = toolbar;

    this.addToToolBar = function(item){
        toolbar.add(item);
    };

    this.setupLogoutButton = function(){
        toolbar.add("->");
        toolbar.add({
            text: 'Logout',
            iconCls:"icon-exit",
            defaultAlign : "right",
            enableToggle : false,
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

    this.CenterPanel = new Ext.Panel({
        id:'erp_app_viewport_center',
        region : 'center',
        margins : '0 0 0 0',
        layout: 'card',
        activeItem : 0,
        minsize : 300,
        items : []
    });

    this.NorthPanel = new Ext.Panel({
        region : 'north',
        height:29,
        layout: 'anchor',
        margins : '0 0 0 0',
        cmargins : '0 0 0 0',
        items:[
        toolbar
        ]
    });

    this.EastPanel = new Ext.Panel({
        region : 'east',
        hidden : true
    });

    var southToolbar = new Ext.Toolbar({
        items:[
        {
            xtype:'tbitem',
            html:"Version 1.0"
        },
        "->",
        {
            xtype:'tbitem',
            html:"<img style='height:35px !important; margin-top:-8px !important;' src='/images/erp_app/organizer/compass-footer-logo-rounded.png' />"
        }
        ]
    });

    this.SouthToolBar = southToolbar;

    this.SouthPanel = new Ext.Panel({
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
        this.WestPanel = new Ext.Panel({
            region : 'west',
            margins : '0 0 0 0',
            cmargins : '0 0 0 0',
            width : 300,
            collapsible: true,
            layout: 'accordion',
            items:accordionMenuItems
        });

        this.Viewport = new Ext.Viewport({
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

Ext.ns('Compass.Component.UserApp.Util');
Compass.Component.UserApp.Util.setActiveCenterItem = function(id, loadRemoteData){
    Ext.ComponentMgr.get('erp_app_viewport_center').layout.setActiveItem(id);
    var activeItem = Ext.ComponentMgr.get(id);
    
    if ( loadRemoteData === undefined || loadRemoteData ) {
        var hasLoad = ( (typeof activeItem.loadRemoteData) != 'undefined' );

        if(hasLoad){
            activeItem.loadRemoteData();
        }
    }

};



