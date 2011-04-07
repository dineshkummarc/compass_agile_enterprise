Compass.ErpApp.Desktop.Applications.Tenancy.TenantTree = Ext.extend(Ext.tree.TreePanel, {
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },

    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    constructor:function(config){
        var self = this;
        config = Ext.apply({
            animate:false,
            enableDD:true,
            containerScroll: true,
            autoDestroy:true,
            split:true,
            tbar:{
                items:[
                {
                    text:'Add Tenant',
                    iconCls:'icon-add',
                    handler:function(btn){
                        var addTenantWindow = new Ext.Window({
                            layout:'fit',
                            width:310,
                            title:'New Tenant',
                            height:100,
                            plain: true,
                            buttonAlign:'center',
                            items: new Ext.FormPanel({
                                labelWidth: 50,
                                frame:false,
                                bodyStyle:'padding:5px 5px 0',
                                width: 425,
                                url:'./tenancy/base/new_tenant',
                                defaults: {
                                    width: 225
                                },
                                items:[
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Schema',
                                    name:'schema',
                                    allowBlank:false
                                }
                                ]
                            }),
                            buttons: [{
                                text:'Submit',
                                listeners:{
                                    'click':function(button){
                                        var window = button.findParentByType('window');
                                        var formPanel = window.findByType('form')[0];
                                        var waitMsg = Ext.Msg.wait('Working','Creating Tenant...');
                                        formPanel.getForm().submit({
                                            reset:true,
                                            success:function(form, action){
                                                waitMsg.hide();
                                                var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                if(obj.success){
                                                    addTenantWindow.close();
                                                    self.root.reload();
                                                }
                                                else{
                                                    Ext.Msg.alert("Error", obj.msg);
                                                }
                                            },
                                            failure:function(form, action){
                                                waitMsg.hide();
                                                Ext.Msg.alert("Error", "Error creating Tenant");
                                            }
                                        });
                                    }
                                }
                            },{
                                text: 'Close',
                                handler: function(){
                                    addTenantWindow.close();
                                }
                            }]
                        });
                        addTenantWindow.show();
                    }
                }
                ]
            },
            root:{
                xtype:'asynctreenode',
                text: 'Tenants',
                id:'root_node',
                allowDrag:false,
                allowDrop:false
            },
            loader:new Ext.tree.TreeLoader({
                dataUrl:'./tenancy/base/tenants'
            }),
            autoScroll:true,
            margins: '5 0 5 5',
            listeners:{
                'contextmenu':function(node, e){
                    e.stopEvent();
                    var contextMenu = null;
                    if(node.attributes['isDomain']){
                        contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:'Update',
                                iconCls:'icon-edit',
                                handler:function(btn){
                                    var updateDomainWindow = new Ext.Window({
                                        layout:'fit',
                                        width:310,
                                        title:'Update Domain',
                                        height:125,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 50,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            width: 425,
                                            url:'./tenancy/base/update_domain',
                                            defaults: {
                                                width: 225
                                            },
                                            items:[
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Host',
                                                name:'host',
                                                value:node.attributes.host,
                                                allowBlank:false
                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Route',
                                                name:'route',
                                                value:node.attributes.route,
                                                allowBlank:false
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'id',
                                                value:node.id
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    var waitMsg = Ext.Msg.wait('Working','Updating Domain...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            waitMsg.hide();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            if(obj.success){
                                                                updateDomainWindow.close();
                                                                node.parentNode.reload();
                                                            }
                                                            else{
                                                                Ext.Msg.alert("Error", obj.msg);
                                                            }
                                                        },
                                                        failure:function(form, action){
                                                            waitMsg.hide();
                                                            Ext.Msg.alert("Error", "Error updating Domain");
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                updateDomainWindow.close();
                                            }
                                        }]
                                    });
                                    updateDomainWindow.show();
                                }
                            },
                            {
                                text:'Delete',
                                iconCls:'icon-delete',
                                handler:function(btn){
                                    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this Domain?', function(btn){
                                        if(btn == 'no'){
                                            return false;
                                        }
                                        else
                                        if(btn == 'yes')
                                        {
                                            self.setWindowStatus('Deleting...');
                                            var conn = new Ext.data.Connection();
                                            conn.request({
                                                url: './tenancy/base/delete_domain',
                                                method: 'POST',
                                                params:{
                                                    id:node.id
                                                },
                                                success: function(response) {
                                                    var obj =  Ext.util.JSON.decode(response.responseText);
                                                    if(obj.success){
                                                        self.clearWindowStatus();
                                                        node.parentNode.reload();
                                                    }
                                                    else{
                                                        Ext.Msg.alert('Error', 'Error deleting Domain');
                                                        self.clearWindowStatus();
                                                    }
                                                },
                                                failure: function(response) {
                                                    self.clearWindowStatus();
                                                    Ext.Msg.alert('Error', 'Error deleting Domain');
                                                }
                                            });
                                        }
                                    })
                                }
                            }
                            ]
                        });
                    }
                    else
                    if(node.attributes['isTenant'])
                    {
                        contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:'Update Tenant',
                                iconCls:'icon-edit',
                                handler:function(btn){
                                    var updateTenantWindow = new Ext.Window({
                                        layout:'fit',
                                        width:310,
                                        title:'Update Tenant',
                                        height:100,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 50,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            width: 425,
                                            url:'./tenancy/base/update_tenant',
                                            defaults: {
                                                width: 225
                                            },
                                            items:[
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Schema',
                                                name:'schema',
                                                value:node.attributes.schema,
                                                allowBlank:false
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'id',
                                                value:node.id
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    var waitMsg = Ext.Msg.wait('Working','Updating Tenant...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            waitMsg.hide();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            if(obj.success){
                                                                updateTenantWindow.close();
                                                                node.parentNode.reload();
                                                            }
                                                            else{
                                                                Ext.Msg.alert("Error", obj.msg);
                                                            }
                                                        },
                                                        failure:function(form, action){
                                                            waitMsg.hide();
                                                            Ext.Msg.alert("Error", "Error updating Tenant");
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                updateTenantWindow.close();
                                            }
                                        }]
                                    });
                                    updateTenantWindow.show();
                                }
                            },
                            {
                                text:'Add Domain',
                                iconCls:'icon-add',
                                handler:function(btn){
                                    var addDomainWindow = new Ext.Window({
                                        layout:'fit',
                                        width:310,
                                        title:'New Domain',
                                        height:125,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 50,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            width: 425,
                                            url:'./tenancy/base/new_domain',
                                            defaults: {
                                                width: 225
                                            },
                                            items:[
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Host',
                                                name:'host',
                                                allowBlank:false
                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Route',
                                                name:'route',
                                                allowBlank:false
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'id',
                                                value:node.id
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    var waitMsg = Ext.Msg.wait('Working','Creating Domain...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            waitMsg.hide();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            if(obj.success){
                                                                addDomainWindow.close();
                                                                node.reload();
                                                            }
                                                            else{
                                                                Ext.Msg.alert("Error", obj.msg);
                                                            }
                                                        },
                                                        failure:function(form, action){
                                                            waitMsg.hide();
                                                            Ext.Msg.alert("Error", "Error creating Domain");
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                addDomainWindow.close();
                                            }
                                        }]
                                    });
                                    addDomainWindow.show();
                                }
                            },
                            {
                                text:'Delete',
                                iconCls:'icon-delete',
                                handler:function(btn){
                                    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this Tenant?', function(btn){
                                        if(btn == 'no'){
                                            return false;
                                        }
                                        else
                                        if(btn == 'yes')
                                        {
                                            self.setWindowStatus('Deleting...');
                                            var conn = new Ext.data.Connection();
                                            conn.request({
                                                url: './tenancy/base/delete_tenant',
                                                method: 'POST',
                                                params:{
                                                    id:node.id
                                                },
                                                success: function(response) {
                                                    var obj =  Ext.util.JSON.decode(response.responseText);
                                                    if(obj.success){
                                                        self.clearWindowStatus();
                                                        node.parentNode.reload();
                                                    }
                                                    else{
                                                        Ext.Msg.alert('Error', 'Error deleting Tenant');
                                                        self.clearWindowStatus();
                                                    }
                                                },
                                                failure: function(response) {
                                                    self.clearWindowStatus();
                                                    Ext.Msg.alert('Error', 'Error deleting Tenant');
                                                }
                                            });
                                        }
                                    })
                                }
                            }
                            ]
                        });
                    }
                    if(contextMenu != null)
                        contextMenu.showAt(e.xy);
                }
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.Tenancy.TenantTree.superclass.constructor.call(this, config);
    }
});

Ext.reg('tenancy_tenanttree', Compass.ErpApp.Desktop.Applications.Tenancy.TenantTree);


