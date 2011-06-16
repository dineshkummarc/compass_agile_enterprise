Compass.ErpApp.Widgets.GoogleMap = {
    addGoogleMap:function(){
        var addGoogleMapWidgetWindow = new Ext.Window({
            layout:'fit',
            width:500,
            title:'Add Login Widget',
            height:130,
            plain: true,
            buttonAlign:'center',
            items: new Ext.FormPanel({
                labelWidth: 100,
                frame:false,
                bodyStyle:'padding:5px 5px 0',
                defaults: {
                    width: 225
                },
                items: [
                {
                    xtype:'textfield',
                    fieldLabel:'Title',
                    width:200,
                    allowBlank:false,
                    id:'googleMapWidgetTitle'
                },
                {
                    xtype:'textfield',
                    fieldLabel:'Address',
                    width:300,
                    allowBlank:false,
                    id:'googleMapWidgetAddress'
                }
                ]
            }),
            buttons: [{
                text:'Submit',
                listeners:{
                    'click':function(button){
                        var window = button.findParentByType('window');
                        var formPanel = window.findByType('form')[0];
                        var basicForm = formPanel.getForm();
                        var title = basicForm.findField('googleMapWidgetTitle').getValue();
                        var address = basicForm.findField('googleMapWidgetAddress').getValue();
                        var data = {
                            title:title,
                            address:address
                        };

                        var tpl = new Ext.Template("<%= render_widget :google_map,\n",
                                                    "   :params => {:address => '{address}',\n",
                                                    "               :title => '{title}'}%>");
                        var content = tpl.apply(data);
                        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(content);
						basicForm.reset();
                    }
                }
            },{
                text: 'Close',
                handler: function(){
                    addGoogleMapWidgetWindow.close();
                }
            }]
        });
        addGoogleMapWidgetWindow.show();
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Google Map',
    iconUrl:'/images/icons/map/map_48x48.png',
    onClick:"Compass.ErpApp.Widgets.GoogleMap.addGoogleMap();"
});