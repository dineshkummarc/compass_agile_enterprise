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
                        
                        var tpl = new Ext.XTemplate("<style type='text/css'>\n",
                            "html { height: 100% }",
                            "body { height: 100%; margin: 0px; padding: 0px }\n",
                            "#map_canvas { height: 100% }\n",
                            "</style>\n",
                            "<script type='text/javascript' src='http://maps.google.com/maps/api/js?sensor=false'>\n",
                            "<\/script>\n",
                            "<div id='map_canvas' style='width:500px;height:500px;border:solid 1px black;'></div>\n",
                            "<script type='text/javascript'>\n",
                            "  var geocoder;\n",
                            "  var map;\n",
                            "  var address = '{address}';\n",
                            "  var locationName = '{title}';\n",
                            "  function initialize() {\n",
                            "    geocoder = new google.maps.Geocoder();",
                            "    geocoder.geocode( { 'address': address}, function(results, status) {\n",
                            "      if (status == google.maps.GeocoderStatus.OK) {\n",
                            "        var myOptions = {\n",
                            "        	zoom: 18,\n",
                            "        	center: results[0].geometry.location,\n",
                            "        	mapTypeId: google.maps.MapTypeId.SATELLITE\n",
                            "    	 };\n",
                            "        map = new google.maps.Map(document.getElementById('map_canvas'),myOptions);\n",
                            "        var marker = new google.maps.Marker({\n",
                            "            map: map,\n",
                            "            title: locationName,\n",
                            "            position: results[0].geometry.location\n",
                            "        });\n",
                            "      } else {\n",
                            "        alert('Geocode was not successful for the following reason: ' + status);\n",
                            "      }\n",
                            "    });\n",
                            "  }\n",
                            "<\/script>\n",
                            "<script type='text/javascript'>initialize();<\/script>);\n");
                        var content = tpl.apply(data);
						
                        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(content);
                        addGoogleMapWidgetWindow.close();
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