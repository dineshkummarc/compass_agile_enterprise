Ext.define("Compass.ErpApp.Organizer.DefaultMenuTreeStore",{
    extend:"Ext.data.TreeStore",
    alias:'widget.defaultmenutreestore',

    constructor: function(config){
        var fields = [{
            name:'text'
        },{
            name:'leaf'
        },{
            name:'iconCls'
        },{
            name:'applicationCardId'
        }];
    
        if(config['additionalFields']){
            fields = fields.concat(config['additionalFields']);
        }

        config = Ext.apply({
            autoLoad:true,
            proxy: {
                type: 'ajax',
                url: config['url']
            },
            root: {
                text: config['rootText'],
                expanded: true,
                iconCls:config['rootIconCls']
            },
            fields:fields
        }, config);
        Compass.ErpApp.Organizer.DefaultMenuTreeStore.superclass.constructor.call(this, config);
    }
});


Ext.define("Compass.ErpApp.Organizer.DefaultMenuTreePanel",{
    extend:"Ext.panel.Panel",
    alias:'widget.defaultmenutree',
    treePanel: null,
    
    constructor: function(config) {
        var setActiveCenterItemFn = function(view, record, item, index, e){
            Compass.ErpApp.Organizer.Layout.setActiveCenterItem(record.data.applicationCardId);
        };

        if(!config['treeConfig'])
            config['treeConfig'] = {}

        if(!config['treeConfig']['listeners'])
            config['treeConfig']['listeners'] = {};
            
        config['treeConfig'].listeners['itemclick'] = setActiveCenterItemFn;
      	
        var menuTreeConfig = Ext.apply({
            animate:true,
            autoScroll:false,
            frame:false,
            containerScroll:true,
            height:300,
            border:false
        }, config['treeConfig']);
        
        var menuTree = Ext.create("Ext.tree.Panel",menuTreeConfig);
        this.treePanel = menuTree;

        config = Ext.apply({
            items:[menuTree],
            listeners:{
                'activate':function(comp){
                    menuTree.getStore().load({
                        node:menuTree.getRootNode
                    });
                }
            }
        }, config);
        
        Compass.ErpApp.Organizer.DefaultMenuTreePanel.superclass.constructor.call(this, config);
    }
});



