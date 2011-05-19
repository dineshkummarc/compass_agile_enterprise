Ext.override(Ext.data.Node, {
    setLeaf: function(value){
        this.leaf = value;
    }
}); 

Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion = Ext.extend(Ext.TabPanel, {
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    deleteSection : function(node){
        var self = this;
        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this section?', function(btn){
            if(btn == 'no'){
                return false;
            }
            else
            if(btn == 'yes')
            {
                self.setWindowStatus('Deleting Section...');
                var conn = new Ext.data.Connection();
                conn.request({
                    url: './knitkit/section/delete',
                    method: 'POST',
                    params:{
                        id:node.id.split('_')[1]
                    },
                    success: function(response) {
                        self.clearWindowStatus();
                        var obj =  Ext.util.JSON.decode(response.responseText);
                        if(obj.success){
                            node.remove(true);
                        }
                        else{
                            Ext.Msg.alert('Error', 'Error deleting section');
                        }
                    },
                    failure: function(response) {
                        self.clearWindowStatus();
                        Ext.Msg.alert('Error', 'Error deleting section');
                    }
                });
            }
        });
    },

    exportSite : function(id){
        var self = this;
        self.setWindowStatus('Exporting theme...');
        window.open('/erp_app/desktop/knitkit/website/export?id='+id,'mywindow','width=400,height=200');
        self.clearWindowStatus();
    },

    deleteSite : function(node){
        var self = this;
        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this website?', function(btn){
            if(btn == 'no'){
                return false;
            }
            else
            if(btn == 'yes')
            {
                self.setWindowStatus('Deleting site...');
                var conn = new Ext.data.Connection();
                conn.request({
                    url: './knitkit/site/delete',
                    method: 'POST',
                    params:{
                        id:node.id.split('_')[1]
                    },
                    success: function(response) {
                        self.clearWindowStatus();
                        var obj =  Ext.util.JSON.decode(response.responseText);
                        if(obj.success){
                            node.remove(true);
                        }
                        else{
                            Ext.Msg.alert('Error', 'Error deleting site');
                        }
                    },
                    failure: function(response) {
                        self.clearWindowStatus();
                        Ext.Msg.alert('Error', 'Error deleting site');
                    }
                });
            }
        });
    },

    publish : function(node){
        var self = this;
        var publishWindow = new Compass.ErpApp.Desktop.Applications.Knitkit.PublishWindow({
            baseParams:{
                id:node.id.split('_')[1]
            },
            url:'./knitkit/site/publish',
            listeners:{
                'publish_success':function(window, response){
                    if(response.success){
                        self.clearWindowStatus();
                        self.getPublications(node);
                    }
                    else{
                        Ext.Msg.alert('Error', 'Error publishing site');
                        self.clearWindowStatus();
                    }
                },
                'publish_failure':function(window, response){
                    self.clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error publishing site');
                }
            }
        });

        publishWindow.show();
    },

    editSectionLayout : function(sectionName, sectionId, websiteId){
        var self = this;
        self.setWindowStatus('Loading section template...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/section/get_layout',
            method: 'POST',
            params:{
                id:sectionId
            },
            success: function(response) {
                self.initialConfig['centerRegion'].editSectionLayout(
                    sectionName,
                    websiteId,
                    sectionId,
                    response.responseText,
                    [{
                        text: 'Insert Content Area',
                        handler: function(btn){
                            var codeMirror = btn.findParentByType('codemirror');
                            Ext.MessageBox.prompt('New File', 'Please enter content area name:', function(btn, text){
                                if(btn == 'ok'){
                                    codeMirror.setValue(codeMirror.getValue() + '<%=render_content(:'+text+')%>');
                                }
                            });
                        }
                    }]);
                self.clearWindowStatus();
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error loading section layout.');
            }
        });
    },

    changeSecurityOnSection : function(node, secure){
        var self = this;
        self.setWindowStatus('Loading securing section...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/section/update_security',
            method: 'POST',
            params:{
                id:node.id.split('_')[1],
                site_id:node.attributes.siteId,
                secure:secure
            },
            success: function(response) {
                var obj = Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.clearWindowStatus();
                    if(secure){
                        node.getUI().getIconEl().className = "x-tree-node-icon icon-document_lock";
                    }
                    else{
                        node.getUI().getIconEl().className = "x-tree-node-icon icon-document";
                    }
                    node.attributes.isSecured = secure;
                }
                else{
                    Ext.Msg.alert('Error', 'Error securing section');
                }
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error securing section.');
            }
        });
    },

    initComponent: function() {
        var self = this;
        this.sitesTree = new Ext.tree.TreePanel({
            dataUrl:'./knitkit/websites',
            root:{
                nodeType: 'async'
            },
            region: 'center',
            rootVisible:false,
            enableDD :true,
            listeners:{
                'nodedragover':function(dragOverEvent){
                    var targetNode = dragOverEvent.target;
                    var dropNode = dragOverEvent.dropNode;

                    if(dropNode.attributes['isWebsiteNavItem'] || dropNode.attributes['isSection']){
                        if((targetNode.parentNode == dropNode.parentNode)){
                            return true;
                        }
                    }

                    return false
                },
                'nodedrop':function(dropEvent){
                    var positionArray = [];
                    var counter = 0;
                    var parent = dropEvent.target.parentNode;
                    var dropNode = dropEvent.dropNode;

                    if(dropNode.attributes['isWebsiteNavItem']){
                        parent.eachChild(function(node){
                            positionArray.push({
                                id:node.attributes.websiteNavItemId,
                                position:counter,
                                klass:'WebsiteNavItem'
                            });
                            counter++;
                        });
                    }
                    else{
                        parent.eachChild(function(node){
                            positionArray.push({
                                id:node.id.split('_')[1],
                                position:counter,
                                klass:'WebsiteSection'
                            });
                            counter++;
                        });
                    }

                    var conn = new Ext.data.Connection();
                    conn.request({
                        url:'./knitkit/position/update',
                        method: 'PUT',
                        jsonData:{
                            position_array:positionArray
                        },
                        success: function(response) {
                            
                        },
                        failure: function(response) {
                            Ext.Msg.alert('Error', 'Error saving positions.');
                        }
                    });

                },
                'click':function(node, e){
                    if(node.attributes['isSection']){
                        self.getArticles(node);
                    }
                    else
                    if(node.attributes['isHost']){
                        var webNavigator = CompassDesktop.getModules().find("id == 'web-navigator-win'");
                        webNavigator.createWindow(node.attributes['url']);
                    }
                },
                'contextmenu':function(node, e){
                    e.stopEvent();
                    var items = [];

                    if(!Compass.ErpApp.Utility.isBlank(node.attributes['url'])){
                        items.push({
                            text:'View In Web Navigator',
                            iconCls:'icon-globe',
                            listeners:{
                                'click':function(){
                                    var webNavigator = CompassDesktop.getModules().find("id == 'web-navigator-win'");
                                    webNavigator.createWindow(node.attributes['url']);
                                }
                            }
                        });
                    }

                    if(node.attributes['isSection']){
                        items.push({
                            text:'View Articles',
                            iconCls:'icon-document',
                            listeners:{
                                'click':function(){
                                    self.getArticles(node);
                                }
                            }
                        });

                        if(node.attributes.isSecured){
                            items.push({
                                text:'Unsecure',
                                iconCls:'icon-document',
                                listeners:{
                                    'click':function(){
                                        self.changeSecurityOnSection(node, false);
                                    }
                                }
                            });
                        }
                        else{
                            items.push({
                                text:'Secure',
                                iconCls:'icon-document_lock',
                                listeners:{
                                    'click':function(){
                                        self.changeSecurityOnSection(node, true);
                                    }
                                }
                            });
                        }

                        items.push({
                            text:'Add Section',
                            iconCls:'icon-add',
                            listeners:{
                                'click':function(){
                                    var addSectionWindow = new Ext.Window({
                                        layout:'fit',
                                        width:375,
                                        title:'New Section',
                                        height:150,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 110,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            url:'./knitkit/section/new',
                                            defaults: {
                                                width: 225
                                            },
                                            items: [
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Title',
                                                allowBlank:false,
                                                name:'title'
                                            },
                                            {
                                                width: 100,
                                                xtype: 'combo',
                                                forceSelection:true,
                                                store: [
                                                ['Page','Page'],
                                                ['Blog','Blog'],
                                                ],
                                                value:'Page',
                                                fieldLabel: 'Type',
                                                name: 'type',
                                                allowBlank: false,
                                                triggerAction: 'all'
                                            },
                                            {
                                                xtype:'radiogroup',
                                                fieldLabel:'Display in menu?',
                                                name:'in_menu',
                                                width:100,
                                                columns:2,
                                                items:[
                                                {
                                                    boxLabel:'Yes',
                                                    name:'in_menu',
                                                    inputValue: 'yes',
                                                    checked:true
                                                },

                                                {
                                                    boxLabel:'No',
                                                    name:'in_menu',
                                                    inputValue: 'no'
                                                }]
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'website_section_id',
                                                value:node.attributes.id.split('_')[1]
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    self.setWindowStatus('Creating section...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            if(obj.success){
                                                                node.setLeaf(false);
                                                                node.appendChild(obj.node);
                                                            }
                                                            else{
                                                                Ext.Msg.alert("Error", obj.msg);
                                                            }
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                addSectionWindow.close();
                                            }
                                        }]
                                    });
                                    addSectionWindow.show();
                                }
                            }
                        });

                        items.push({
                            text:'Update Section',
                            iconCls:'icon-edit',
                            listeners:{
                                'click':function(){
                                    var updateSectionWindow = new Ext.Window({
                                        layout:'fit',
                                        width:375,
                                        title:'Update Section',
                                        height:125,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 110,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            url:'./knitkit/section/update',
                                            defaults: {
                                                width: 225
                                            },
                                            items: [
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Title',
                                                id:'knitkitUpdateWebsiteSectionTitle',
                                                value:node.attributes.text,
                                                name:'title'
                                            },
                                            {
                                                xtype:'radiogroup',
                                                fieldLabel:'Display in menu?',
                                                id:'knitkitUpdateSectionDisplayInMenu',
                                                name:'in_menu',
                                                width:100,
                                                columns:2,
                                                items:[
                                                {
                                                    boxLabel:'Yes',
                                                    name:'in_menu',
                                                    inputValue: 'yes',
                                                    checked:node.attributes.inMenu
                                                },

                                                {
                                                    boxLabel:'No',
                                                    name:'in_menu',
                                                    inputValue: 'no',
                                                    checked:!node.attributes.inMenu
                                                }]
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'id',
                                                value:node.attributes.id.split('_')[1]
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    self.setWindowStatus('Updating section...');
                                                    formPanel.getForm().submit({
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var newSectionTitle = Ext.getCmp('knitkitUpdateWebsiteSectionTitle').getValue();
                                                            node.setText(newSectionTitle);
                                                            node.attributes.inMenu = Ext.getCmp('knitkitUpdateSectionDisplayInMenu').getValue() == 'yes';
                                                            updateSectionWindow.close();
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                updateSectionWindow.close();
                                            }
                                        }]
                                    });
                                    updateSectionWindow.show();
                                }
                            }
                        });

                        //no layouts for blogs.
                        if(Compass.ErpApp.Utility.isBlank(node.attributes['isBlog']) && node.attributes['hasLayout']){
                            items.push({
                                text:'Edit Layout',
                                iconCls:'icon-edit',
                                listeners:{
                                    'click':function(){
                                        self.editSectionLayout(node.text, node.id.split('_')[1], node.attributes.siteId);
                                    }
                                }
                            });
                        }
                        else
                        if(Compass.ErpApp.Utility.isBlank(node.attributes['isBlog'])){
                            items.push({
                                text:'Add Layout',
                                iconCls:'icon-add',
                                listeners:{
                                    'click':function(){
                                        var sectionId = node.id.split('_')[1];
                                        var conn = new Ext.data.Connection();
                                        conn.request({
                                            url: './knitkit/section/add_layout',
                                            method: 'POST',
                                            params:{
                                                id:sectionId
                                            },
                                            success: function(response) {
                                                self.clearWindowStatus();
                                                var obj =  Ext.util.JSON.decode(response.responseText);
                                                if(obj.success){
                                                    node.attributes.hasLayout = true;
                                                    self.editSectionLayout(node.text, sectionId, node.attributes.siteId);
                                                }
                                                else
                                                {
                                                    Ext.Msg.alert('Status', obj.message);
                                                }
                                            },
                                            failure: function(response) {
                                                self.clearWindowStatus();
                                                Ext.Msg.alert('Status', 'Error adding layout.');
                                            }
                                        });
                                    }
                                }
                            });
                        }

                        items.push({
                            text:'Delete ' + node.attributes["type"],
                            iconCls:'icon-delete',
                            listeners:{
                                'click':function(){
                                    self.deleteSection(node);
                                }
                            }
                        });
                    }
                    else
                    if(node.attributes['isWebsite']){
                        if(ErpApp.Authentication.RoleManager.hasRole(['admin','publisher'])){
                            items.push({
                                text:'Publish',
                                iconCls:'icon-document_up',
                                listeners:{
                                    'click':function(){
                                        self.publish(node);
                                    }
                                }
                            });
                        }

                        items.push({
                            text:'Publications',
                            iconCls:'icon-documents',
                            listeners:{
                                'click':function(){
                                    self.getPublications(node);
                                }
                            }
                        });

                        items.push({
                            text:'View Inquiries',
                            iconCls:'icon-document',
                            listeners:{
                                'click':function(){
                                    self.initialConfig['centerRegion'].viewWebsiteInquiries(node.attributes.id.split('_')[1], node.attributes.title);
                                }
                            }
                        });

                        items.push({
                            text:'Update Site',
                            iconCls:'icon-edit',
                            listeners:{
                                'click':function(){
                                    var editWebsiteWindow = new Ext.Window({
                                        layout:'fit',
                                        width:375,
                                        title:'Update Website',
                                        height:250,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 110,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            url:'./knitkit/site/update',
                                            defaults: {
                                                width: 225
                                            },
                                            items: [
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Name',
                                                allowBlank:false,
                                                name:'name',
                                                value:node.attributes['name']
                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Title',
                                                id:'knitkitUpdateSiteTitle',
                                                allowBlank:false,
                                                name:'title',
                                                value:node.attributes['title']
                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Sub Title',
                                                allowBlank:true,
                                                name:'subtitle',
                                                value:node.attributes['subtitle']

                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Email',
                                                allowBlank:false,
                                                name:'email',
                                                value:node.attributes['email']
                                            },
                                            {
                                                xtype:'radiogroup',
                                                fieldLabel:'Auto Activate Publication?',
                                                name:'auto_activate_publication',
                                                id:'knitkitAutoActivatePublication',
                                                width:100,
                                                columns:2,
                                                items:[
                                                {
                                                    boxLabel:'Yes',
                                                    name:'auto_activate_publication',
                                                    inputValue: 'yes',
                                                    checked:node.attributes['autoActivatePublication']
                                                },
                                                {
                                                    boxLabel:'No',
                                                    name:'auto_activate_publication',
                                                    inputValue: 'no',
                                                    checked:!node.attributes['autoActivatePublication']
                                                }]
                                            },
                                            {
                                                xtype:'radiogroup',
                                                fieldLabel:'Email Inquiries?',
                                                name:'email_inquiries',
                                                id:'knitkitEmailInquiries',
                                                width:100,
                                                columns:2,
                                                items:[
                                                {
                                                    boxLabel:'Yes',
                                                    name:'email_inquiries',
                                                    inputValue: 'yes',
                                                    checked:node.attributes['emailInquiries'],
                                                    listeners:{
                                                        scope:this,
                                                        'check':function(checkbox, checked){
                                                            if(checked)
                                                            {
                                                                Ext.Msg.alert("Warning","ActionMailer must be setup to send emails");
                                                            }
                                                        }
                                                    }
                                                },

                                                {
                                                    boxLabel:'No',
                                                    name:'email_inquiries',
                                                    inputValue: 'no',
                                                    checked:!node.attributes['emailInquiries']
                                                }]
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'id',
                                                value:node.attributes.id.split('_')[1]
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    self.setWindowStatus('Updating website...');
                                                    formPanel.getForm().submit({
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            node.setText(form.findField('knitkitUpdateSiteTitle').getValue());
                                                            node.attributes.emailInquiries = form.findField('knitkitEmailInquiries').getValue().inputValue == 'yes';
                                                            node.attributes.autoActivatePublication = form.findField('knitkitAutoActivatePublication').getValue().inputValue == 'yes';
                                                            editWebsiteWindow.close();
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            Ext.Msg.alert("Error", "Error updating website");
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                editWebsiteWindow.close();
                                            }
                                        }]
                                    });
                                    editWebsiteWindow.show();
                                }
                            }
                        });

                        items.push({
                            text:'Delete',
                            iconCls:'icon-delete',
                            listeners:{
                                'click':function(){
                                    self.deleteSite(node);
                                }
                            }
                        });

                        items.push({
                            text:'Export',
                            iconCls:'icon-document_out',
                            listeners:{
                                'click':function(){
                                    self.exportSite(node.id.split('_')[1]);
                                }
                            }
                        });
                    }
                    else
                    if(node.attributes['isHostRoot']){
                        items.push({
                            text:'Add Host',
                            iconCls:'icon-add',
                            listeners:{
                                'click':function(){
                                    var addHostWindow = new Ext.Window({
                                        layout:'fit',
                                        width:310,
                                        title:'Add Host',
                                        height:100,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 50,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            width: 425,
                                            url:'./knitkit/site/add_host',
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
                                                xtype:'hidden',
                                                name:'id',
                                                value:node.attributes.websiteId
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    self.setWindowStatus('Adding Host...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            if(obj.success){
                                                                addHostWindow.close();
                                                                node.appendChild(obj.node);
                                                            }
                                                            else{
                                                                Ext.Msg.alert("Error", obj.msg);
                                                            }
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            Ext.Msg.alert("Error", "Error adding Host");
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                addHostWindow.close();
                                            }
                                        }]
                                    });
                                    addHostWindow.show();
                                }
                            }
                        });
                    }
                    else
                    if(node.attributes['isHost']){
                        items.push({
                            text:'Update',
                            iconCls:'icon-edit',
                            listeners:{
                                'click':function(){
                                    var updateHostWindow = new Ext.Window({
                                        layout:'fit',
                                        width:310,
                                        title:'Update Host',
                                        height:100,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 50,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            width: 425,
                                            url:'./knitkit/site/update_host',
                                            defaults: {
                                                width: 225
                                            },
                                            items:[
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Host',
                                                id:'knitkitUpdateWebsiteHostHost',
                                                name:'host',
                                                value:node.attributes.host,
                                                allowBlank:false
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'id',
                                                value:node.attributes.websiteHostId
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    self.setWindowStatus('Updating Host...');
                                                    formPanel.getForm().submit({
                                                        reset:false,
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            if(obj.success){
                                                                var newHost = Ext.getCmp('knitkitUpdateWebsiteHostHost').getValue();
                                                                node.attributes.host = newHost;
                                                                node.setText(newHost);
                                                                updateHostWindow.close();
                                                            }
                                                            else{
                                                                Ext.Msg.alert("Error", obj.msg);
                                                            }
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            Ext.Msg.alert("Error", "Error updating Host");
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                updateHostWindow.close();
                                            }
                                        }]
                                    });
                                    updateHostWindow.show();
                                }
                            }
                        });

                        items.push({
                            text:'Delete',
                            iconCls:'icon-delete',
                            listeners:{
                                'click':function(){
                                    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this Host?', function(btn){
                                        if(btn == 'no'){
                                            return false;
                                        }
                                        else
                                        if(btn == 'yes')
                                        {
                                            self.setWindowStatus('Deleting Host...');
                                            var conn = new Ext.data.Connection();
                                            conn.request({
                                                url: './knitkit/site/delete_host',
                                                method: 'POST',
                                                params:{
                                                    id:node.attributes.websiteHostId
                                                },
                                                success: function(response) {
                                                    self.clearWindowStatus();
                                                    var obj =  Ext.util.JSON.decode(response.responseText);
                                                    if(obj.success){
                                                        node.remove(true);
                                                    }
                                                    else{
                                                        Ext.Msg.alert('Error', 'Error deleting Host');
                                                    }
                                                },
                                                failure: function(response) {
                                                    self.clearWindowStatus();
                                                    Ext.Msg.alert('Error', 'Error deleting Host');
                                                }
                                            });
                                        }
                                    });
                                }
                            }
                        });
                    }
                    else if(node.attributes['isSectionRoot']){
                        items.push({
                            text:'Add Section',
                            iconCls:'icon-add',
                            listeners:{
                                'click':function(){
                                    var addSectionWindow = new Ext.Window({
                                        layout:'fit',
                                        width:375,
                                        title:'New Section',
                                        height:150,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 110,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            url:'./knitkit/section/new',
                                            defaults: {
                                                width: 225
                                            },
                                            items: [
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Title',
                                                allowBlank:false,
                                                name:'title'
                                            },
                                            {
                                                width: 100,
                                                xtype: 'combo',
                                                forceSelection:true,
                                                store: [
                                                ['Page','Page'],
                                                ['Blog','Blog'],
                                                ],
                                                value:'Page',
                                                fieldLabel: 'Type',
                                                name: 'type',
                                                allowBlank: false,
                                                triggerAction: 'all'
                                            },
                                            {
                                                xtype:'radiogroup',
                                                fieldLabel:'Display in menu?',
                                                name:'in_menu',
                                                width:100,
                                                columns:2,
                                                items:[
                                                {
                                                    boxLabel:'Yes',
                                                    name:'in_menu',
                                                    inputValue: 'yes',
                                                    checked:true
                                                },

                                                {
                                                    boxLabel:'No',
                                                    name:'in_menu',
                                                    inputValue: 'no'
                                                }]
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'websiteId',
                                                value:node.attributes.websiteId
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    self.setWindowStatus('Creating section...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            if(obj.success){
                                                                node.appendChild(obj.node);
                                                            }
                                                            else{
                                                                Ext.Msg.alert("Error", obj.msg);
                                                            }
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                addSectionWindow.close();
                                            }
                                        }]
                                    });
                                    addSectionWindow.show();
                                }
                            }
                        });
                    }
                    else
                    if(node.attributes['isMenuRoot']){
                        items.push({
                            text:'Add Menu',
                            iconCls:'icon-add',
                            handler:function(btn){
                                var addMenuWindow = new Ext.Window({
                                    layout:'fit',
                                    width:375,
                                    title:'New Menu',
                                    height:100,
                                    plain: true,
                                    buttonAlign:'center',
                                    items: new Ext.FormPanel({
                                        labelWidth: 50,
                                        frame:false,
                                        bodyStyle:'padding:5px 5px 0',
                                        url:'./knitkit/website_nav/new',
                                        defaults: {
                                            width: 225
                                        },
                                        items: [
                                        {
                                            xtype:'textfield',
                                            fieldLabel:'name',
                                            allowBlank:false,
                                            name:'name'
                                        },
                                        {
                                            xtype:'hidden',
                                            name:'website_id',
                                            value:node.attributes.websiteId
                                        }
                                        ]
                                    }),
                                    buttons: [{
                                        text:'Submit',
                                        listeners:{
                                            'click':function(button){
                                                var window = button.findParentByType('window');
                                                var formPanel = window.findByType('form')[0];
                                                self.setWindowStatus('Creating menu...');
                                                formPanel.getForm().submit({
                                                    reset:true,
                                                    success:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                        if(obj.success){
                                                            node.appendChild(obj.node);
                                                        }
                                                        else{
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                    },
                                                    failure:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                        Ext.Msg.alert("Error", obj.msg);
                                                    }
                                                });
                                            }
                                        }
                                    },{
                                        text: 'Close',
                                        handler: function(){
                                            addMenuWindow.close();
                                        }
                                    }]
                                });
                                addMenuWindow.show();
                            }
                        });
                    }
                    else
                    if(node.attributes['isWebsiteNav']){
                        items.push({
                            text:'Add Menu Item',
                            iconCls:'icon-add',
                            handler:function(btn){
                                var addMenuItemWindow = new Ext.Window({
                                    layout:'fit',
                                    width:375,
                                    title:'New Menu Item',
                                    height:175,
                                    plain: true,
                                    buttonAlign:'center',
                                    items: new Ext.FormPanel({
                                        labelWidth: 50,
                                        frame:false,
                                        bodyStyle:'padding:5px 5px 0',
                                        url:'./knitkit/website_nav/add_menu_item',
                                        defaults: {
                                            width: 225
                                        },
                                        items: [
                                        {
                                            xtype:'textfield',
                                            fieldLabel:'Title',
                                            allowBlank:false,
                                            name:'title'
                                        },
                                        {
                                            xtype:'combo',
                                            fieldLabel:'Link to',
                                            name:'link_to',
                                            id:'knitkit_nav_item_link_to',
                                            allowBlank:false,
                                            width:100,
                                            forceSelection:true,
                                            editable:false,
                                            autoSelect:true,
                                            typeAhead: false,
                                            mode: 'local',
                                            triggerAction: 'all',
                                            store:[
                                            ['website_section','Section'],
                                            ['url','Url']
                                            ],
                                            value:'website_section',
                                            listeners:{
                                                'change':function(combo, newValue, oldValue){
                                                    switch(newValue){
                                                        case 'website_section':
                                                            Ext.getCmp('knitkit_create_website_nav_item_section').show();
                                                            Ext.getCmp('knitkit_create_website_nav_item_url').hide();
                                                            break;
                                                        case 'url':
                                                            Ext.getCmp('knitkit_create_website_nav_item_section').hide();
                                                            Ext.getCmp('knitkit_create_website_nav_item_url').show();
                                                            break;
                                                    }
                                                }
                                            }
                                        },
                                       
                                        {
                                            xtype:'combo',
                                            id:'knitkit_create_website_nav_item_section',
                                            hiddenName:'website_section_id',
                                            name:'website_section_id',
                                            loadingText:'Retrieving Sections...',
                                            store:{
                                                xtype:'jsonstore',
                                                autoLoad:true,
                                                baseParams:{
                                                    website_id:node.attributes.websiteId
                                                },
                                                url:'./knitkit/section/existing_sections',
                                                fields:[
                                                {
                                                    name:'id'
                                                },
                                                {
                                                    name:'title'

                                                }
                                                ]
                                            },
                                            forceSelection:true,
                                            editable:false,
                                            fieldLabel:'Section',
                                            autoSelect:true,
                                            typeAhead: false,
                                            mode: 'local',
                                            displayField:'title',
                                            valueField:'id',
                                            triggerAction: 'all'
                                        },
                                        {
                                            xtype:'textfield',
                                            fieldLabel:'Url',
                                            id:'knitkit_create_website_nav_item_url',
                                            hidden:true,
                                            name:'url'
                                        },
                                        {
                                            xtype:'hidden',
                                            name:'website_nav_id',
                                            value:node.attributes.websiteNavId
                                        }
                                        ]
                                    }),
                                    buttons: [{
                                        text:'Submit',
                                        listeners:{
                                            'click':function(button){
                                                var window = button.findParentByType('window');
                                                var formPanel = window.findByType('form')[0];
                                                self.setWindowStatus('Creating menu item...');
                                                formPanel.getForm().submit({
                                                    reset:true,
                                                    success:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                        if(obj.success){
                                                            node.appendChild(obj.node);
                                                        }
                                                        else{
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                    },
                                                    failure:function(form, action){
                                                        self.clearWindowStatus();
                                                        if(action.response == null){
                                                            Ext.Msg.alert("Error", 'Could not create menu item');
                                                        }
                                                        else{
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                       
                                                    }
                                                });
                                            }
                                        }
                                    },{
                                        text: 'Close',
                                        handler: function(){
                                            addMenuItemWindow.close();
                                        }
                                    }]
                                });
                                addMenuItemWindow.show();
                            }
                        });

                        items.push({
                            text:'Update',
                            iconCls:'icon-edit',
                            handler:function(btn){
                                var updateMenuWindow = new Ext.Window({
                                    layout:'fit',
                                    width:375,
                                    title:'Update Menu',
                                    height:100,
                                    plain: true,
                                    buttonAlign:'center',
                                    items: new Ext.FormPanel({
                                        labelWidth: 50,
                                        frame:false,
                                        bodyStyle:'padding:5px 5px 0',
                                        url:'./knitkit/website_nav/update',
                                        defaults: {
                                            width: 225
                                        },
                                        items: [
                                        {
                                            xtype:'textfield',
                                            fieldLabel:'Name',
                                            value:node.text,
                                            id:'knitkit_website_nav_update_name',
                                            allowBlank:false,
                                            name:'name'
                                        },
                                        {
                                            xtype:'hidden',
                                            name:'website_nav_id',
                                            value:node.attributes.websiteNavId
                                        }
                                        ]
                                    }),
                                    buttons: [{
                                        text:'Submit',
                                        listeners:{
                                            'click':function(button){
                                                var window = button.findParentByType('window');
                                                var formPanel = window.findByType('form')[0];
                                                self.setWindowStatus('Creating menu...');
                                                formPanel.getForm().submit({
                                                    reset:false,
                                                    success:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                        if(obj.success){
                                                            var newText = Ext.getCmp('knitkit_website_nav_update_name').getValue();
                                                            node.getUI().getTextEl().innerHTML = newText;
                                                        }
                                                        else{
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                    },
                                                    failure:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                        Ext.Msg.alert("Error", obj.msg);
                                                    }
                                                });
                                            }
                                        }
                                    },{
                                        text: 'Close',
                                        handler: function(){
                                            updateMenuWindow.close();
                                        }
                                    }]
                                });
                                updateMenuWindow.show();
                            }
                        });

                        items.push({
                            text:'Delete',
                            iconCls:'icon-delete',
                            handler:function(btn){
                                Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this menu?', function(btn){
                                    if(btn == 'no'){
                                        return false;
                                    }
                                    else
                                    if(btn == 'yes')
                                    {
                                        self.setWindowStatus('Deleting menu...');
                                        var conn = new Ext.data.Connection();
                                        conn.request({
                                            url: './knitkit/website_nav/delete',
                                            method: 'POST',
                                            params:{
                                                id:node.attributes.websiteNavId
                                            },
                                            success: function(response) {
                                                self.clearWindowStatus();
                                                var obj =  Ext.util.JSON.decode(response.responseText);
                                                if(obj.success){
                                                    node.remove(true);
                                                }
                                                else{
                                                    Ext.Msg.alert('Error', 'Error deleting menu');
                                                }
                                            },
                                            failure: function(response) {
                                                self.clearWindowStatus();
                                                Ext.Msg.alert('Error', 'Error deleting menu');
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    }
                    else
                    if(node.attributes['isWebsiteNavItem'])
                    {
                        items.push({
                            text:'Update Menu Item',
                            iconCls:'icon-edit',
                            handler:function(btn){
                                var addMenuItemWindow = new Ext.Window({
                                    layout:'fit',
                                    width:375,
                                    title:'Update Menu Item',
                                    height:175,
                                    plain: true,
                                    buttonAlign:'center',
                                    items: new Ext.FormPanel({
                                        labelWidth: 50,
                                        frame:false,
                                        bodyStyle:'padding:5px 5px 0',
                                        url:'./knitkit/website_nav/update_menu_item',
                                        defaults: {
                                            width: 225
                                        },
                                        items: [
                                        {
                                            xtype:'textfield',
                                            fieldLabel:'Title',
                                            value:node.text,
                                            allowBlank:false,
                                            name:'title'
                                        },
                                        {
                                            xtype:'combo',
                                            fieldLabel:'Link to',
                                            name:'link_to',
                                            id:'knitkit_nav_item_link_to',
                                            allowBlank:false,
                                            width:100,
                                            forceSelection:true,
                                            editable:false,
                                            autoSelect:true,
                                            typeAhead: false,
                                            mode: 'local',
                                            triggerAction: 'all',
                                            store:[
                                            ['website_section','Section'],
                                            //['article','Article'],
                                            ['url','Url']
                                            ],
                                            value:node.attributes.linkToType,
                                            listeners:{
                                                'change':function(combo, newValue, oldValue){
                                                    switch(newValue){
                                                        case 'website_section':
                                                            Ext.getCmp('knitkit_website_nav_item_section').show();
                                                            Ext.getCmp('knitkit_website_nav_item_article').hide();
                                                            Ext.getCmp('knitkit_website_nav_item_url').hide();
                                                            break;
                                                        case 'article':
                                                            Ext.getCmp('knitkit_website_nav_item_section').hide();
                                                            Ext.getCmp('knitkit_website_nav_item_article').show();
                                                            Ext.getCmp('knitkit_website_nav_item_url').hide();
                                                            break;
                                                        case 'url':
                                                            Ext.getCmp('knitkit_website_nav_item_section').hide();
                                                            Ext.getCmp('knitkit_website_nav_item_article').hide();
                                                            Ext.getCmp('knitkit_website_nav_item_url').show();
                                                            break;
                                                    }
                                                }
                                            }
                                        },
                                        {
                                            xtype:'combo',
                                            id:'knitkit_website_nav_item_article',
                                            hiddenName:'article_id',
                                            hidden:(node.attributes.linkToType == 'website_section' || node.attributes.linkToType == 'url'),
                                            name:'article_id',
                                            loadingText:'Retrieving Articles...',
                                            store:{
                                                xtype:'jsonstore',
                                                autoLoad:true,
                                                baseParams:{
                                                    website_id:node.attributes.websiteId
                                                },
                                                url:'./knitkit/articles/existing_articles',
                                                fields:[
                                                {
                                                    name:'id'
                                                },
                                                {
                                                    name:'title'

                                                }
                                                ],
                                                listeners:{
                                                    'load':function(store, records, options){
                                                        Ext.getCmp('knitkit_website_nav_item_article').setValue(node.attributes.linkedToId);
                                                    }
                                                }
                                            },
                                            forceSelection:true,
                                            editable:false,
                                            fieldLabel:'Article',
                                            autoSelect:true,
                                            typeAhead: false,
                                            mode: 'local',
                                            displayField:'title',
                                            valueField:'id',
                                            triggerAction: 'all'
                                        },
                                        {
                                            xtype:'combo',
                                            id:'knitkit_website_nav_item_section',
                                            hiddenName:'website_section_id',
                                            hidden:(node.attributes.linkToType == 'url' || node.attributes.linkToType == 'article'),
                                            name:'website_section_id',
                                            loadingText:'Retrieving Sections...',
                                            store:{
                                                xtype:'jsonstore',
                                                autoLoad:true,
                                                baseParams:{
                                                    website_id:node.attributes.websiteId
                                                },
                                                url:'./knitkit/section/existing_sections',
                                                fields:[
                                                {
                                                    name:'id'
                                                },
                                                {
                                                    name:'title'

                                                }
                                                ],
                                                listeners:{
                                                    'load':function(store, records, options){
                                                        Ext.getCmp('knitkit_website_nav_item_section').setValue(node.attributes.linkedToId);
                                                    }
                                                }
                                            },
                                            forceSelection:true,
                                            editable:false,
                                            fieldLabel:'Section',
                                            autoSelect:true,
                                            typeAhead: false,
                                            mode: 'local',
                                            displayField:'title',
                                            valueField:'id',
                                            triggerAction: 'all'
                                        },
                                        {
                                            xtype:'textfield',
                                            fieldLabel:'Url',
                                            value:node.attributes.url,
                                            id:'knitkit_website_nav_item_url',
                                            hidden:(node.attributes.linkToType == 'website_section' || node.attributes.linkToType == 'article'),
                                            name:'url'
                                        },
                                        {
                                            xtype:'hidden',
                                            name:'website_nav_item_id',
                                            value:node.attributes.websiteNavItemId
                                        }
                                        ]
                                    }),
                                    buttons: [{
                                        text:'Submit',
                                        listeners:{
                                            'click':function(button){
                                                var window = button.findParentByType('window');
                                                var formPanel = window.findByType('form')[0];
                                                self.setWindowStatus('Updating menu item...');
                                                formPanel.getForm().submit({
                                                    reset:false,
                                                    success:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                        if(obj.success){
                                                            node.attributes.linkedToId = obj.linkedToId;
                                                            node.attributes.linkToType = obj.linkToType;
                                                            node.attributes.url = obj.url;
                                                            node.getUI().getTextEl().innerHTML = obj.title;
                                                        }
                                                        else{
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                    },
                                                    failure:function(form, action){
                                                        self.clearWindowStatus();
                                                        if(action.response == null){
                                                            Ext.Msg.alert("Error", 'Could not create menu item');
                                                        }
                                                        else{
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                       
                                                    }
                                                });
                                            }
                                        }
                                    },{
                                        text: 'Close',
                                        handler: function(){
                                            addMenuItemWindow.close();
                                        }
                                    }]
                                });
                                addMenuItemWindow.show();
                            }
                        });

                        items.push({
                            text:'Delete',
                            iconCls:'icon-delete',
                            handler:function(btn){
                                Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this menu item?', function(btn){
                                    if(btn == 'no'){
                                        return false;
                                    }
                                    else
                                    if(btn == 'yes')
                                    {
                                        self.setWindowStatus('Deleting menu item...');
                                        var conn = new Ext.data.Connection();
                                        conn.request({
                                            url: './knitkit/website_nav/delete_menu_item',
                                            method: 'POST',
                                            params:{
                                                id:node.websiteNavItemId
                                            },
                                            success: function(response) {
                                                self.clearWindowStatus();
                                                var obj =  Ext.util.JSON.decode(response.responseText);
                                                if(obj.success){
                                                    node.remove(true);
                                                }
                                                else{
                                                    Ext.Msg.alert('Error', 'Error deleting menu item');
                                                }
                                            },
                                            failure: function(response) {
                                                self.clearWindowStatus();
                                                Ext.Msg.alert('Error', 'Error deleting menu item');
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    }
                    var contextMenu = new Ext.menu.Menu({
                        items:items
                    });
                    contextMenu.showAt(e.xy);
                }
            }
        });

        this.contentsCardPanel = new Ext.Panel({
            layout:'card',
            region:'south',
            autoDestroy:true,
            split:true,
            height:300,
            collapsible:true
        });

        var layout = new Ext.Panel({
            layout: 'border',
            autoDestroy:true,
            title:'Websites',
            items: [this.sitesTree,this.contentsCardPanel],
            tbar:{
                items:[
                {
                    text:'New Website',
                    iconCls:'icon-add',
                    handler:function(btn){
                        var addWebsiteWindow = new Ext.Window({
                            layout:'fit',
                            width:375,
                            title:'New Website',
                            height:300,
                            plain: true,
                            buttonAlign:'center',
                            items: new Ext.FormPanel({
                                labelWidth: 110,
                                frame:false,
                                bodyStyle:'padding:5px 5px 0',
                                url:'./knitkit/site/new',
                                defaults: {
                                    width: 225
                                },
                                items: [
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Name',
                                    allowBlank:false,
                                    name:'name'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Host',
                                    allowBlank:false,
                                    name:'host'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Title',
                                    allowBlank:false,
                                    name:'title'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Sub Title',
                                    allowBlank:true,
                                    name:'subtitle'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Email',
                                    allowBlank:false,
                                    name:'email'
                                },
                                {
                                    xtype:'radiogroup',
                                    fieldLabel:'Auto Activate Publication?',
                                    name:'auto_activate_publication',
                                    width:100,
                                    columns:2,
                                    items:[
                                    {
                                        boxLabel:'Yes',
                                        name:'auto_activate_publication',
                                        inputValue: 'yes'
                                    },
                                    {
                                        boxLabel:'No',
                                        name:'auto_activate_publication',
                                        inputValue: 'no',
                                        checked:true
                                    }]
                                },
                                {
                                    xtype:'radiogroup',
                                    fieldLabel:'Email Inquiries',
                                    name:'email_inquiries',
                                    width:100,
                                    columns:2,
                                    items:[
                                    {
                                        boxLabel:'Yes',
                                        name:'email_inquiries',
                                        inputValue: 'yes',
                                        checked:false,
                                        listeners:{
                                            scope:this,
                                            'check':function(checkbox, checked){
                                                if(checked)
                                                {
                                                    Ext.Msg.alert("Warning","ActionMailer must be setup to send emails");
                                                }
                                            }
                                        }
                                    },
                                    {
                                        boxLabel:'No',
                                        name:'email_inquiries',
                                        inputValue: 'no',
                                        checked:true
                                    }
                                    ]
                                }
                                ]
                            }),
                            buttons: [{
                                text:'Submit',
                                listeners:{
                                    'click':function(button){
                                        var window = button.findParentByType('window');
                                        var formPanel = window.findByType('form')[0];
                                        self.setWindowStatus('Creating website...');
                                        formPanel.getForm().submit({
                                            success:function(form, action){
                                                self.clearWindowStatus();
                                                var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                if(obj.success){
                                                    self.sitesTree.getRootNode().reload();
                                                    addWebsiteWindow.close();
                                                }
                                            },
                                            failure:function(form, action){
                                                self.clearWindowStatus();
                                                Ext.Msg.alert("Error", "Error creating website");
                                            }
                                        });
                                    }
                                }
                            },{
                                text: 'Close',
                                handler: function(){
                                    addWebsiteWindow.close();
                                }
                            }]
                        });
                        addWebsiteWindow.show();
                    }
                },
                {
                    text:'Import Website',
                    iconCls:'icon-globe',
                    handler:function(btn){
                        var importWebsiteWindow = new Ext.Window({
                            layout:'fit',
                            width:375,
                            title:'Import Website',
                            height:100,
                            plain: true,
                            buttonAlign:'center',
                            items: new Ext.FormPanel({
                                labelWidth: 110,
                                frame:false,
                                fileUpload: true,
                                bodyStyle:'padding:5px 5px 0',
                                url:'./knitkit/site/import',
                                defaults: {
                                    width: 225
                                },
                                items: [
                                {
                                    xtype:'fileuploadfield',
                                    fieldLabel:'Upload Website',
                                    buttonText:'Upload',
                                    buttonOnly:false,
                                    allowBlank:false,
                                    name:'website_data'
                                }
                                ]
                            }),
                            buttons: [{
                                text:'Submit',
                                listeners:{
                                    'click':function(button){
                                        var window = button.findParentByType('window');
                                        var formPanel = window.findByType('form')[0];
                                        self.setWindowStatus('Importing website...');
                                        formPanel.getForm().submit({
                                            success:function(form, action){
                                                self.clearWindowStatus();
                                                var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                if(obj.success){
                                                    self.sitesTree.getRootNode().reload();
                                                    importWebsiteWindow.close();
                                                }
                                                else{
                                                    Ext.Msg.alert("Error", obj.message);
                                                }
                                            },
                                            failure:function(form, action){
                                                self.clearWindowStatus();
                                                var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                if(obj != null){
                                                    Ext.Msg.alert("Error", obj.message);
                                                }
                                                else{
                                                    Ext.Msg.alert("Error", "Error importing website");
                                                }
                                            }
                                        });
                                    }
                                }
                            },{
                                text: 'Close',
                                handler: function(){
                                    importWebsiteWindow.close();
                                }
                            }]
                        });
                        importWebsiteWindow.show();
                    }
                }
                ]
            }
        });

        this.items = [layout, {
            xtype:'knitkit_themestreepanel',
            centerRegion:this.initialConfig['module'].centerRegion
        }];
        
        Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion.superclass.initComponent.call(this, arguments);
        
        this.setActiveTab(0);
    },

    getArticles : function(node){
        this.contentsCardPanel.removeAll(true);
        var xtype = 'knitkit_'+node.attributes.type.toLowerCase()+'articlesgridpanel';
        this.contentsCardPanel.add({
            xtype:xtype,
            title:node.attributes.siteName + ' - ' + node.attributes.text + ' - Articles',
            sectionId:node.id.split('_')[1],
            centerRegion:this.initialConfig['module'].centerRegion,
            siteId:node.attributes.siteId
        });
        this.contentsCardPanel.getLayout().setActiveItem(this.contentsCardPanel.items.length - 1);
    },

    getPublications : function(node){
        this.contentsCardPanel.removeAll(true);
        this.contentsCardPanel.add({
            xtype:'knitkit_publishedgridpanel',
            title:node.attributes.siteName + ' Publications',
            siteId:node.id.split('_')[1],
            centerRegion:this.initialConfig['module'].centerRegion
        });
        this.contentsCardPanel.getLayout().setActiveItem(this.contentsCardPanel.items.length - 1);
    },

    constructor : function(config) {
        config = Ext.apply({
            region:'west',
            split:true,
            width:350,
            collapsible:true
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion.superclass.constructor.call(this, config);
    }
});

Ext.reg('knitkit_westregion', Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion);
