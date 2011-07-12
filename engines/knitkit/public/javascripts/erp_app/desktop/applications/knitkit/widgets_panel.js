Compass.ErpApp.Desktop.Applications.Knitkit.WidgetsPanel = function() {
    var widgetsStore = Ext.create('Ext.data.Store',{
        autoDestroy: true,
        fields:['name', 'iconUrl', 'onClick'],
        data:Compass.ErpApp.Widgets.AvailableWidgets
    });

    this.widgetsDataView = Ext.create("Ext.view.View",{
        //TODO_EXTJS4 this is added to fix error should be removed when extjs 4 releases fix.
        loadMask: false,
        autoDestroy:true,
        style:'overflow:auto',
        store:widgetsStore,
        tpl: new Ext.XTemplate(
            '<tpl for=".">',
            '<div class="thumb-wrap" id="{name}" onclick="{onClick}">',
            '<div class="thumb"><img src="{iconUrl}" class="thumb-img"></div>',
            '<span>{name}</span></div>',
            '</tpl>'
            )
    });

    var widgetsPanel = new Ext.Panel({
        id:'widgets',
        autoDestroy:true,
        title:'Available Widgets',
        region:'center',
        margins: '5 5 5 0',
        layout:'fit',
        items: this.widgetsDataView
    });

    this.layout = new Ext.Panel({
        layout: 'border',
        autoDestroy:true,
        title:'Widgets',
        items: [widgetsPanel]
    });
}



