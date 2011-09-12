Compass.ErpApp.Widgets.Orders = {
    add:function(){
        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror("<%= render_widget :orders %>");
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Orders',
    iconUrl:'/images/icons/package/package_48x48.png',
    onClick:Compass.ErpApp.Widgets.Orders.add
});