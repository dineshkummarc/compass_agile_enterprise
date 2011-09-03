Compass.ErpApp.Widgets.DynamicForms = {
    addDynamicForm:function(){
        var addDynamicFormWidgetWindow = Ext.create("Ext.window.Window",{
            layout:'fit',
            width:375,
            title:'Add DynamicForm Widget',
            height:190,
            plain: true,
            buttonAlign:'center',
            items: Ext.create("Ext.form.Panel",{
                labelWidth: 100,
                frame:false,
                bodyStyle:'padding:5px 5px 0',
                defaults: {
                    width: 325
                },
                items: [
                {
                    xtype:'combo',
                    id:'WidgetDynamicFormModelName',
                    value:'',
                    loadingText:'Retrieving Dynamic Form Models ...',
                    store:Ext.create('Ext.data.Store',{
                        proxy:{
                          type:'ajax',
                          reader:{
                              type:'json',
                              root: 'dynamic_form_model'
                          },
                          url:'/erp_forms/erp_app/desktop/dynamic_forms/models/index'
                        },
                        fields:[
                        {
                            name:'id'
                        },
                        {
                            name:'model_name'

                        }
                        ]
                    }),
                    forceSelection:true,
                    editable:true,
                    fieldLabel:'Dynamic Form Model Name (Class)',
                    autoSelect:true,
                    typeAhead: true,
                    mode: 'remote',
                    displayField:'model_name',
                    valueField:'model_name',
                    triggerAction: 'all',
                    allowBlank:false
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
                        var formPanel = window.query('form')[0];
                        var basicForm = formPanel.getForm();

                        var WidgetDynamicFormModelName = basicForm.findField('WidgetDynamicFormModelName');
                        var data = {};
                        data.WidgetDynamicFormModelName = WidgetDynamicFormModelName.getValue();

                        var WidgetDynamicFormWidth = basicForm.findField('WidgetDynamicFormWidth');
                        data.WidgetDynamicFormWidth = WidgetDynamicFormWidth.getValue();
                        tpl = new Ext.XTemplate(
                            "<% # Optional Parameters:\n",
                            "   # internal_identifier: Models can have multiple forms\n",
                            "   #                      Leave blank if you want to use the default form\n",
                            "   #                      Specify internal_identifier to choose a specific form %>\n",
                            "<%= render_widget :dynamic_forms,\n",
                            "   :params => {:model_name => '{WidgetDynamicFormModelName}',\n",
                            "               :internal_identifier => '',\n",
                            "               :width => {WidgetDynamicFormWidth}} %>");
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
    onClick:Compass.ErpApp.Widgets.DynamicForms.addDynamicForm
});
