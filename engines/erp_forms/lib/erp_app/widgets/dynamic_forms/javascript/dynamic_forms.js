Compass.ErpApp.Widgets.DynamicForms = {
    addDynamicForm:function(){
        var addDynamicFormWidgetWindow = new Ext.Window({
            layout:'fit',
            width:375,
            title:'Add DynamicForm Widget',
            height:190,
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
                    fieldLabel:'Dynamic Form Model Name (Class)',
                    allowBlank:false,
                    value:'',
                    id:'WidgetDynamicFormModelName'
                },
                {
                    xtype:'textfield',
                    fieldLabel:'Form Width in Pixels',
                    allowBlank:false,
                    value:'350',
                    id:'WidgetDynamicFormWidth'
                }
                ]
            }),
            buttons: [{
                text:'Submit',
                listeners:{
                    'click':function(button){
                        var tpl = null;
                        var content = null;
                        var window = button.findParentByType('window');
                        var formPanel = window.findByType('form')[0];
                        var basicForm = formPanel.getForm();

                        var WidgetDynamicFormModelName = basicForm.findField('WidgetDynamicFormModelName');
                        var data = {};
                        data.WidgetDynamicFormModelName = WidgetDynamicFormModelName.getValue();

                        var WidgetDynamicFormWidth = basicForm.findField('WidgetDynamicFormWidth');
                        data.WidgetDynamicFormWidth = WidgetDynamicFormWidth.getValue();
                        tpl = new Ext.XTemplate("<%= render_widget :dynamic_forms,\n",
                                                "   :params => {:model_name => '{WidgetDynamicFormModelName}',\n",
                                                "               :width => '{WidgetDynamicFormWidth}'} %>");
                        content = tpl.apply(data);

                        //add rendered template to center region editor
                        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(content);
                        addDynamicFormWidgetWindow.close();
                    }
                }
            },{
                text: 'Close',
                handler: function(){
                    addDynamicFormWidgetWindow.close();
                }
            }]
        });
        addDynamicFormWidgetWindow.show();
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Dynamic Forms',
    iconUrl:'/images/icons/document_text/document_text_48x48.png',
    onClick:"Compass.ErpApp.Widgets.DynamicForms.addDynamicForm();"
});
