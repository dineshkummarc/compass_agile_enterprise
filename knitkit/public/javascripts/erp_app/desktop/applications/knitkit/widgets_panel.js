Compass.ErpApp.Desktop.Applications.Knitkit.WidgetsPanel = function() {
  var widgetsStore = Ext.create('Ext.data.Store',{
    autoDestroy: true,
    fields:['name', 'iconUrl', 'onClick', 'about'],
    data:Compass.ErpApp.Widgets.AvailableWidgets
  });

  this.widgetsDataView = Ext.create("Ext.view.View",{
    style:'overflow:auto',
    itemSelector: 'div.thumb-wrap',
    store:widgetsStore,
    tpl: [
    '<tpl for=".">',
    '<div data-qtip="{about}" class="thumb-wrap" id="{name}">',
    '<div class="thumb"><img src="{iconUrl}" class="thumb-img"></div>',
    '<span>{name}</span></div>',
    '</tpl>',
    '<div class="x-clear"></div>'
    ],
    listeners:{
      'itemcontextmenu':function(view, record, htmlitem, index, e, options){
        e.stopEvent();
        var contextMenu = Ext.create("Ext.menu.Menu",{
          items:[{
            text:'Add Widget',
            iconCls:'icon-add',
            handler:function(btn){
              record.data.onClick();
            }
          }]
          });
        contextMenu.showAt(e.xy);
      }
    }
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



