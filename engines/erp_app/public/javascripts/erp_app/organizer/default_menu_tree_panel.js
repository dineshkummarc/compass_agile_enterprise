Ext.define("Compass.ErpApp.Organizer.DefaultMenuTreePanel",{
    extend:"Ext.panel.Panel",
    id:'file_manager-win',
    alias:'widget.defaultmenutree',
    treePanel: null,
    initComponent: function() {
        var menuTreeConfig = Ext.apply({
            animate:true,
            autoScroll:false,
            frame:true,
            autoLoad : false,
            containerScroll: true,
            border: false,
            width: "auto",
            height: "auto"
        }, this.initialConfig['treeConfig']);
        
        var menuTree = new Ext.tree.TreePanel(menuTreeConfig);
        this.treePanel = menuTree;

        this.items = [menuTree];

        Compass.ErpApp.Organizer.DefaultMenuTreePanel.superclass.initComponent.call(this, arguments);
    }
});



