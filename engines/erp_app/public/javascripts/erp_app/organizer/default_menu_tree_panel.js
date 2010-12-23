Ext.tree.TreeLoader.override({
    requestData : function(node, callback){
        if(this.fireEvent("beforeload", this, node, callback) !== false){
            this.transId = Ext.Ajax.request({
                method:this.requestMethod,
                url: this.dataUrl||this.url,
                success: this.handleResponse,
                failure: this.handleFailure,
                timeout: this.timeout || 30000,
                scope: this,
                argument: {callback: callback, node: node},
                params: this.getParams(node)
            });
        }else{
            // if the load is cancelled, make sure we notify
            // the node that we are done
            if(typeof callback == "function"){
                callback();
            }
        }
    }
}); 

Ext.ns("Compass.ErpApp.Organizer");

Compass.ErpApp.Organizer.DefaultMenuTreePanel = Ext.extend(Ext.Panel, {
    
    treePanel: null,

    initComponent: function() {
        var menuRoot = new Ext.tree.AsyncTreeNode({
            text: this.initialConfig['rootNodeTitle'],
            draggable:false,
            iconCls:this.initialConfig['menuRootIconCls']
        });

        var menuTreeConfig = Ext.apply({
            animate:true,
            autoScroll:false,
            frame:true,
            autoLoad : false,
            enableDD:false,
            containerScroll: true,
            border: false,
            width: "auto",
            height: "auto"
        }, this.initialConfig['treeConfig']);
        
        var menuTree = new Ext.tree.TreePanel(menuTreeConfig);
        this.treePanel = menuTree;

        menuTree.setRootNode(menuRoot);

        this.items = [menuTree];

        menuRoot.expand();

        Compass.ErpApp.Organizer.DefaultMenuTreePanel.superclass.initComponent.call(this, arguments);
    }
});

Ext.reg('defaultmenutree', Compass.ErpApp.Organizer.DefaultMenuTreePanel);



