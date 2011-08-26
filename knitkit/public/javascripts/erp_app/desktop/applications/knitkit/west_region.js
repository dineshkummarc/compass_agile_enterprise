Ext.tree.Panel.updateNodeIcon = function(htmlItem, oldCssCls, newCssCls){
    var nodeIconEl = Ext.get(htmlItem.children[0].children[0].children[3]);
    nodeIconEl.removeCls(oldCssCls);
    nodeIconEl.addCls(newCssCls);
};

Ext.tree.Panel.updateNodeText = function(htmlItem, oldText, newText){
    var stringFinder = "</div></td>";
    oldText = oldText + stringFinder;
    newText = newText + stringFinder;
    htmlItem.innerHTML = htmlItem.innerHTML.replace(oldText, newText);
};

Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion",{
    extend:"Ext.tab.Panel",
    alias:'widget.knitkit_westregion',
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
                    url: '/knitkit/erp_app/desktop/section/delete',
                    method: 'POST',
                    params:{
                        id:node.data.id.split('_')[1]
                    },
                    success: function(response) {
                        self.clearWindowStatus();
                        var obj =  Ext.decode(response.responseText);
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
        window.open('/erp_app/desktop/knitkit/erp_app/desktop/site/export?id='+id,'mywindow','width=400,height=200');
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
                    url: '/knitkit/erp_app/desktop/site/delete',
                    method: 'POST',
                    params:{
                        id:node.data.id.split('_')[1]
                    },
                    success: function(response) {
                        self.clearWindowStatus();
                        var obj =  Ext.decode(response.responseText);
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
            url:'/knitkit/erp_app/desktop/site/publish',
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
            url: '/knitkit/erp_app/desktop/section/get_layout',
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
                                    codeMirror.setValue(codeMirror.getValue() + '<%=render_content_area(:'+text+')%>');
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

    changeSecurityOnSection : function(node, secure, htmlItem){
        var self = this;
        self.setWindowStatus('Loading securing section...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: '/knitkit/erp_app/desktop/section/update_security',
            method: 'POST',
            params:{
                id:node.data.id.split('_')[1],
                site_id:node.data.siteId,
                secure:secure
            },
            success: function(response) {
                var obj = Ext.decode(response.responseText);
                if(obj.success){
                    self.clearWindowStatus();
                    if(secure){
                        Ext.tree.Panel.updateNodeIcon(htmlItem, 'icon-document', 'icon-document_lock');
                    }
                    else{
                        Ext.tree.Panel.updateNodeIcon(htmlItem, 'icon-document_lock', 'icon-document');
                    }
                    node.data.isSecured = secure;
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
        
        var store = Ext.create('Ext.data.TreeStore', {
            proxy:{
                type: 'ajax',
                url: '/knitkit/erp_app/desktop/websites'
            },
            root: {
                text: 'Websites',
                expanded: true
            },
            fields:[
            {
                name:'isWebsiteNavItem'
            },
            {
                name:'text'
            },
            {
                name:'iconCls'
            },
            {
                name:'leaf'
            },
            {
                name:'isSection'
            },
            {
                name:'isHost'
            },
            {
                name:'isSecured'
            },
            {
                name:'url'
            },
            {
                name:'inMenu'
            },
            {
                name:'isBlog'
            },
            {
                name:'hasLayout'
            },
            {
                name:'siteId'
            },
            {
                name:'type'
            },
            {
                name:'isWebsite'
            },
            {
                name:'name'
            },
            {
                name:'title'
            },
            {
                name:'subtitle'
            },
            {
                name:'email'
            },
            {
                name:'autoActivatePublication'
            },
            {
                name:'emailInquiries'
            },
            {
                name:'isHostRoot'
            },
            {
                name:'websiteHostId'
            },
            {
                name:'host'
            },
            {
                name:'websiteId'
            },
            {
                name:'isSectionRoot'
            },
            {
                name:'isWebsiteNav'
            },
            {
                name:'isMenuRoot'
            },
            {
                name:'linkToType'
            },
            {
                name:'linkToId'
            },
            {
                name:'websiteNavItemId'
            },
            {
                name:'type'
            },
            {
                name:'siteName'
            },
            {
                name:'websiteNavId'
            }
            ]
        });

        this.sitesTree = new Ext.tree.TreePanel({
            viewConfig: {
                //TODO_EXTJS4 this is added to fix error should be removed when extjs 4 releases fix.
                loadMask: false,
                plugins: {
                    ptype: 'treeviewdragdrop'
                },
                listeners:{
                    'beforedrop':function(node, data, overModel, dropPosition,dropFunction,options){
                        if(overModel.data['isWebsiteNavItem'] || overModel.data['isSection']){
                            if((overModel.parentNode.data['isSectionRoot'])){
                                return true;
                            }
                        }
                        return false;
                    },
                    'drop':function(node, data, overModel, dropPosition, options){
                        var positionArray = [];
                        var counter = 0;
                        var dropNode = data.records[0];

                        if(dropNode.data['isWebsiteNavItem']){
                            overModel.parentNode.eachChild(function(node){
                                positionArray.push({
                                    id:node.data.websiteNavItemId,
                                    position:counter,
                                    klass:'WebsiteNavItem'
                                });
                                counter++;
                            });
                        }
                        else{
                            overModel.parentNode.eachChild(function(node){
                                positionArray.push({
                                    id:node.data.id.split('_')[1],
                                    position:counter,
                                    klass:'WebsiteSection'
                                });
                                counter++;
                            });
                        }

                        var conn = new Ext.data.Connection();
                        conn.request({
                            url:'/knitkit/erp_app/desktop/position/update',
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
                    }
                }
            },
            store:store,
            region: 'center',
            rootVisible:false,
            enableDD :true,
            listeners:{
                'itemclick':function(view, record, item, index, e){
                    e.stopEvent();
                    if(record.data['isSection']){
                        self.getArticles(record);
                    }
                    else
                    if(record.data['isHost']){
                        var webNavigator = window.compassDesktop.getModule('web-navigator-win');
                        webNavigator.createWindow(record.data['url']);
                    }
                },
                'itemcontextmenu':function(view, record, htmlItem, index, e){
                    e.stopEvent();
                    var items = [];

                    if(!Compass.ErpApp.Utility.isBlank(record.data['url'])){
                        items.push({
                            text:'View In Web Navigator',
                            iconCls:'icon-globe',
                            listeners:{
                                'click':function(){
                                    var webNavigator = window.compassDesktop.getModule('web-navigator-win');
                                    webNavigator.createWindow(record.data['url']);
                                }
                            }
                        });
                    }

                    if(record.data['isSection']){
                        items.push({
                            text:'View Articles',
                            iconCls:'icon-document',
                            listeners:{
                                'click':function(){
                                    self.getArticles(record);
                                }
                            }
                        });

                        if(record.data.isSecured){
                            items.push({
                                text:'Unsecure',
                                iconCls:'icon-document',
                                listeners:{
                                    'click':function(){
                                        self.changeSecurityOnSection(record, false, htmlItem);
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
                                        self.changeSecurityOnSection(record, true, htmlItem);
                                    }
                                }
                            });
                        }

                        items.push({
                            text:'Add Section',
                            iconCls:'icon-add',
                            listeners:{
                                'click':function(){
                                    var addSectionWindow = Ext.create("Ext.window.Window",{
                                        layout:'fit',
                                        width:375,
                                        title:'Add Section',
                                        height:150,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 110,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            url:'/knitkit/erp_app/desktop/section/new',
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
                                                value:record.data.id.split('_')[1]
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.query('.form')[0];
                                                    self.setWindowStatus('Creating section...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj = Ext.decode(action.response.responseText);
                                                            if(obj.success){
                                                                record.appendChild(obj.node);
                                                            }
                                                            else{
                                                                Ext.Msg.alert("Error", obj.msg);
                                                            }
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.decode(action.response.responseText);
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
                                    var updateSectionWindow = Ext.create("Ext.window.Window",{
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
                                            url:'/knitkit/erp_app/desktop/section/update',
                                            defaults: {
                                                width: 225
                                            },
                                            items: [
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Title',
                                                id:'knitkitUpdateWebsiteSectionTitle',
                                                value:record.data.text,
                                                name:'title'
                                            },
                                            {
                                                xtype:'radiogroup',
                                                fieldLabel:'Display in menu?',
                                                id:'knitkitUpdateSectionDisplayInMenu',
                                                name:'in_menu',
                                                columns:2,
                                                items:[
                                                {
                                                    boxLabel:'Yes',
                                                    name:'in_menu',
                                                    inputValue: 'yes',
                                                    checked:record.data.inMenu
                                                },

                                                {
                                                    boxLabel:'No',
                                                    name:'in_menu',
                                                    inputValue: 'no',
                                                    checked:!record.data.inMenu
                                                }]
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'id',
                                                value:record.data.id.split('_')[1]
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.query('.form')[0];
                                                    self.setWindowStatus('Updating section...');
                                                    formPanel.getForm().submit({
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var newSectionTitle = Ext.getCmp('knitkitUpdateWebsiteSectionTitle').getValue();
                                                            Ext.tree.Panel.updateNodeText(htmlItem, record.data.text, newSectionTitle);
                                                            record.data.text = newSectionTitle;
                                                            record.data.inMenu = Ext.getCmp('knitkitUpdateSectionDisplayInMenu').getValue() == 'yes';
                                                            updateSectionWindow.close();
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.decode(action.response.responseText);
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
                        if(Compass.ErpApp.Utility.isBlank(record.data['isBlog']) && record.data['hasLayout']){
                            items.push({
                                text:'Edit Layout',
                                iconCls:'icon-edit',
                                listeners:{
                                    'click':function(){
                                        self.editSectionLayout(record.data.text, record.data.id.split('_')[1], record.data.siteId);
                                    }
                                }
                            });
                        }
                        else
                        if(Compass.ErpApp.Utility.isBlank(record.data['isBlog'])){
                            items.push({
                                text:'Add Layout',
                                iconCls:'icon-add',
                                listeners:{
                                    'click':function(){
                                        var sectionId = record.data.id.split('_')[1];
                                        var conn = new Ext.data.Connection();
                                        conn.request({
                                            url: '/knitkit/erp_app/desktop/section/add_layout',
                                            method: 'POST',
                                            params:{
                                                id:sectionId
                                            },
                                            success: function(response) {
                                                self.clearWindowStatus();
                                                var obj =  Ext.decode(response.responseText);
                                                if(obj.success){
                                                    record.data.hasLayout = true;
                                                    self.editSectionLayout(record.data.text, sectionId, record.data.siteId);
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
                            text:'Delete ' + record.data["type"],
                            iconCls:'icon-delete',
                            listeners:{
                                'click':function(){
                                    self.deleteSection(record);
                                }
                            }
                        });
                    }
                    else
                    if(record.data['isWebsite']){
                        if(ErpApp.Authentication.RoleManager.hasRole(['admin','publisher'])){
                            items.push({
                                text:'Publish',
                                iconCls:'icon-document_up',
                                listeners:{
                                    'click':function(){
                                        self.publish(record);
                                    }
                                }
                            });
                        }

                        items.push({
                            text:'Publications',
                            iconCls:'icon-documents',
                            listeners:{
                                'click':function(){
                                    self.getPublications(record);
                                }
                            }
                        });

                        items.push({
                            text:'View Inquiries',
                            iconCls:'icon-document',
                            listeners:{
                                'click':function(){
                                    self.initialConfig['centerRegion'].viewWebsiteInquiries(record.data.id.split('_')[1], record.data.title);
                                }
                            }
                        });

                        items.push({
                            text:'Update Website',
                            iconCls:'icon-edit',
                            listeners:{
                                'click':function(){
                                    var editWebsiteWindow = Ext.create("Ext.window.Window",{
                                        layout:'fit',
                                        width:375,
                                        title:'Update Website',
                                        height:250,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: Ext.create("Ext.form.Panel",{
                                            labelWidth: 110,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            url:'/knitkit/erp_app/desktop/site/update',
                                            defaults: {
                                                width: 225
                                            },
                                            items: [
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Name',
                                                allowBlank:false,
                                                name:'name',
                                                value:record.data['name']
                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Title',
                                                id:'knitkitUpdateSiteTitle',
                                                allowBlank:false,
                                                name:'title',
                                                value:record.data['title']
                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Sub Title',
                                                allowBlank:true,
                                                name:'subtitle',
                                                value:record.data['subtitle']

                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Email',
                                                allowBlank:false,
                                                name:'email',
                                                value:record.data['email']
                                            },
                                            {
                                                xtype:'radiogroup',
                                                fieldLabel:'Auto Activate Publication?',
                                                name:'auto_activate_publication',
                                                id:'knitkitAutoActivatePublication',
                                                columns:2,
                                                items:[
                                                {
                                                    boxLabel:'Yes',
                                                    name:'auto_activate_publication',
                                                    inputValue: 'yes',
                                                    checked:record.data['autoActivatePublication']
                                                },
                                                {
                                                    boxLabel:'No',
                                                    name:'auto_activate_publication',
                                                    inputValue: 'no',
                                                    checked:!record.data['autoActivatePublication']
                                                }]
                                            },
                                            {
                                                xtype:'radiogroup',
                                                fieldLabel:'Email Inquiries?',
                                                name:'email_inquiries',
                                                id:'knitkitEmailInquiries',
                                                columns:2,
                                                items:[
                                                {
                                                    boxLabel:'Yes',
                                                    name:'email_inquiries',
                                                    inputValue: 'yes',
                                                    checked:record.data['emailInquiries'],
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
                                                    checked:!record.data['emailInquiries']
                                                }]
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'id',
                                                value:record.data.id.split('_')[1]
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.query('form')[0];
                                                    self.setWindowStatus('Updating website...');
                                                    formPanel.getForm().submit({
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            record.data['name'] = form.findField('name').getValue();
                                                            record.data['title'] = form.findField('title').getValue();
                                                            record.data['subtitle'] = form.findField('subtitle').getValue();
                                                            record.data['email'] = form.findField('email').getValue();
                                                            //node.setText(node.attributes['title']);
                                                            record.data.emailInquiries = form.findField('knitkitEmailInquiries').getValue().inputValue == 'yes';
                                                            record.data.autoActivatePublication = form.findField('knitkitAutoActivatePublication').getValue().inputValue == 'yes';
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
                                    self.deleteSite(record);
                                }
                            }
                        });

                        items.push({
                            text:'Export',
                            iconCls:'icon-document_out',
                            listeners:{
                                'click':function(){
                                    self.exportSite(record.data.id.split('_')[1]);
                                }
                            }
                        });
                    }
                    else
                    if(record.data['isHostRoot']){
                        items.push({
                            text:'Add Host',
                            iconCls:'icon-add',
                            listeners:{
                                'click':function(){
                                    var addHostWindow = Ext.create("Ext.window.Window",{
                                        layout:'fit',
                                        width:310,
                                        title:'Add Host',
                                        height:100,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: Ext.create("Ext.form.Panel",{
                                            labelWidth: 50,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            width: 425,
                                            url:'/knitkit/erp_app/desktop/site/add_host',
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
                                                value:record.data.websiteId
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.query('form')[0];
                                                    self.setWindowStatus('Adding Host...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.decode(action.response.responseText);
                                                            if(obj.success){
                                                                addHostWindow.close();
                                                                record.appendChild(obj.node);
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
                    if(record.data['isHost']){
                        items.push({
                            text:'Update',
                            iconCls:'icon-edit',
                            listeners:{
                                'click':function(){
                                    var updateHostWindow = Ext.create("Ext.window.Window",{
                                        layout:'fit',
                                        width:310,
                                        title:'Update Host',
                                        height:100,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: Ext.create("Ext.form.Panel",{
                                            labelWidth: 50,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            width: 425,
                                            url:'/knitkit/erp_app/desktop/site/update_host',
                                            defaults: {
                                                width: 225
                                            },
                                            items:[
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Host',
                                                id:'knitkitUpdateWebsiteHostHost',
                                                name:'host',
                                                value:record.data.host,
                                                allowBlank:false
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'id',
                                                value:record.data.websiteHostId
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.query('form')[0];
                                                    self.setWindowStatus('Updating Host...');
                                                    formPanel.getForm().submit({
                                                        reset:false,
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.decode(action.response.responseText);
                                                            if(obj.success){
                                                                var newHost = Ext.getCmp('knitkitUpdateWebsiteHostHost').getValue();
                                                                record.data.host = newHost;
                                                                Ext.tree.Panel.updateNodeText(htmlItem, record.data.text, newHost);
                                                                record.data.text = newHost;
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
                                                url: '/knitkit/erp_app/desktop/site/delete_host',
                                                method: 'POST',
                                                params:{
                                                    id:record.data.websiteHostId
                                                },
                                                success: function(response) {
                                                    self.clearWindowStatus();
                                                    var obj = Ext.decode(response.responseText);
                                                    if(obj.success){
                                                        record.remove(true);
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
                    else if(record.data['isSectionRoot']){
                        items.push({
                            text:'Add Section',
                            iconCls:'icon-add',
                            listeners:{
                                'click':function(){
                                    var addSectionWindow = Ext.create("Ext.window.Window",{
                                        layout:'fit',
                                        width:375,
                                        title:'New Section',
                                        height:150,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: Ext.create("Ext.form.Panel",{
                                            labelWidth: 110,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            url:'/knitkit/erp_app/desktop/section/new',
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
                                                value:record.data.websiteId
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.query('form')[0];
                                                    self.setWindowStatus('Creating section...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj = Ext.decode(action.response.responseText);
                                                            if(obj.success){
                                                                record.appendChild(obj.node);
                                                            }
                                                            else{
                                                                Ext.Msg.alert("Error", obj.msg);
                                                            }
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj = Ext.decode(action.response.responseText);
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
                    if(record.data['isMenuRoot']){
                        items.push({
                            text:'Add Menu',
                            iconCls:'icon-add',
                            handler:function(btn){
                                var addMenuWindow = Ext.create("Ext.window.Window",{
                                    layout:'fit',
                                    width:375,
                                    title:'New Menu',
                                    height:100,
                                    plain: true,
                                    buttonAlign:'center',
                                    items: Ext.create("Ext.form.Panel",{
                                        labelWidth: 50,
                                        frame:false,
                                        bodyStyle:'padding:5px 5px 0',
                                        url:'/knitkit/erp_app/desktop/website_nav/new',
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
                                            value:record.data.websiteId
                                        }
                                        ]
                                    }),
                                    buttons: [{
                                        text:'Submit',
                                        listeners:{
                                            'click':function(button){
                                                var window = button.findParentByType('window');
                                                var formPanel = window.query('form')[0];
                                                self.setWindowStatus('Creating menu...');
                                                formPanel.getForm().submit({
                                                    reset:true,
                                                    success:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj = Ext.decode(action.response.responseText);
                                                        if(obj.success){
                                                            record.appendChild(obj.node);
                                                        }
                                                        else{
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                    },
                                                    failure:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj = Ext.decode(action.response.responseText);
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
                    if(record.data['isWebsiteNav']){
                        items.push({
                            text:'Add Menu Item',
                            iconCls:'icon-add',
                            handler:function(btn){
                                var addMenuItemWindow = Ext.create("Ext.window.Window",{
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
                                        url:'/knitkit/erp_app/desktop/website_nav/add_menu_item',
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
                                            store:Ext.create("Ext.data.Store",{
                                                proxy:{
                                                    type:'ajax',
                                                    url:'/knitkit/erp_app/desktop/section/existing_sections',
                                                    reader:{
                                                        type:'json'
                                                    },
                                                    extraParams:{
                                                        website_id:record.data.websiteId
                                                    }
                                                },
                                                autoLoad:true,
                                                fields:[
                                                {
                                                    name:'id'
                                                },
                                                {
                                                    name:'title'

                                                }
                                                ]
                                            }),
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
                                            value:record.data.websiteNavId
                                        }
                                        ]
                                    }),
                                    buttons: [{
                                        text:'Submit',
                                        listeners:{
                                            'click':function(button){
                                                var window = button.findParentByType('window');
                                                var formPanel = window.query('form')[0];
                                                self.setWindowStatus('Creating menu item...');
                                                formPanel.getForm().submit({
                                                    reset:true,
                                                    success:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj = Ext.decode(action.response.responseText);
                                                        if(obj.success){
                                                            record.appendChild(obj.node);
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
                                                            var obj = Ext.decode(action.response.responseText);
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
                                var updateMenuWindow = Ext.create("Ext.window.Window",{
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
                                        url:'/knitkit/erp_app/desktop/website_nav/update',
                                        defaults: {
                                            width: 225
                                        },
                                        items: [
                                        {
                                            xtype:'textfield',
                                            fieldLabel:'Name',
                                            value:record.data.text,
                                            id:'knitkit_website_nav_update_name',
                                            allowBlank:false,
                                            name:'name'
                                        },
                                        {
                                            xtype:'hidden',
                                            name:'website_nav_id',
                                            value:record.data.websiteNavId
                                        }
                                        ]
                                    }),
                                    buttons: [{
                                        text:'Submit',
                                        listeners:{
                                            'click':function(button){
                                                var window = button.findParentByType('window');
                                                var formPanel = window.query('form')[0];
                                                self.setWindowStatus('Creating menu...');
                                                formPanel.getForm().submit({
                                                    reset:false,
                                                    success:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj = Ext.decode(action.response.responseText);
                                                        if(obj.success){
                                                            var newText = Ext.getCmp('knitkit_website_nav_update_name').getValue();
                                                            Ext.tree.Panel.updateNodeText(htmlItem, record.data.text, newText);
                                                            record.data.text = newText;
                                                        }
                                                        else{
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                    },
                                                    failure:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj = Ext.decode(action.response.responseText);
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
                                            url: '/knitkit/erp_app/desktop/website_nav/delete',
                                            method: 'POST',
                                            params:{
                                                id:record.data.websiteNavId
                                            },
                                            success: function(response) {
                                                self.clearWindowStatus();
                                                var obj = Ext.decode(response.responseText);
                                                if(obj.success){
                                                    record.remove(true);
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
                    if(record.data['isWebsiteNavItem'])
                    {
                        items.push({
                            text:'Update Menu Item',
                            iconCls:'icon-edit',
                            handler:function(btn){
                                var addMenuItemWindow = Ext.create("Ext.window.Window",{
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
                                        url:'/knitkit/erp_app/desktop/website_nav/update_menu_item',
                                        defaults: {
                                            width: 225
                                        },
                                        items: [
                                        {
                                            xtype:'textfield',
                                            fieldLabel:'Title',
                                            value:record.data.text,
                                            allowBlank:false,
                                            name:'title'
                                        },
                                        {
                                            xtype:'combo',
                                            fieldLabel:'Link to',
                                            name:'link_to',
                                            id:'knitkit_nav_item_link_to',
                                            allowBlank:false,
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
                                            value:record.data.linkToType,
                                            listeners:{
                                                'change':function(combo, newValue, oldValue){
                                                    switch(newValue){
                                                        case 'website_section':
                                                            Ext.getCmp('knitkit_website_nav_item_section').show();
                                                            //Ext.getCmp('knitkit_website_nav_item_article').hide();
                                                            Ext.getCmp('knitkit_website_nav_item_url').hide();
                                                            break;
                                                        case 'article':
                                                            Ext.getCmp('knitkit_website_nav_item_section').hide();
                                                            //Ext.getCmp('knitkit_website_nav_item_article').show();
                                                            Ext.getCmp('knitkit_website_nav_item_url').hide();
                                                            break;
                                                        case 'url':
                                                            Ext.getCmp('knitkit_website_nav_item_section').hide();
                                                            //Ext.getCmp('knitkit_website_nav_item_article').hide();
                                                            Ext.getCmp('knitkit_website_nav_item_url').show();
                                                            break;
                                                    }
                                                }
                                            }
                                        },
                                        {
                                            xtype:'combo',
                                            id:'knitkit_website_nav_item_section',
                                            hiddenName:'website_section_id',
                                            name:'website_section_id',
                                            loadingText:'Retrieving Sections...',
                                            store:Ext.create("Ext.data.Store",{
                                                proxy:{
                                                    type:'ajax',
                                                    url:'/knitkit/erp_app/desktop/section/existing_sections',
                                                    reader:{
                                                        type:'json'
                                                    },
                                                    extraParams:{
                                                        website_id:record.data.websiteId
                                                    }
                                                },
                                                autoLoad:true,
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
                                                        Ext.getCmp('knitkit_website_nav_item_section').setValue(record.data.linkedToId);
                                                    }
                                                }
                                            }),
                                            forceSelection:true,
                                            editable:false,
                                            fieldLabel:'Section',
                                            autoSelect:true,
                                            typeAhead: false,
                                            mode: 'local',
                                            displayField:'title',
                                            valueField:'id',
                                            triggerAction: 'all',
                                            hidden:(record.data.linkToType != 'website_section' && record.data.linkToType != 'article')
                                        },
                                        {
                                            xtype:'textfield',
                                            fieldLabel:'Url',
                                            value:record.data.url,
                                            id:'knitkit_website_nav_item_url',
                                            hidden:(record.data.linkToType == 'website_section' || record.data.linkToType == 'article'),
                                            name:'url'
                                        },
                                        {
                                            xtype:'hidden',
                                            name:'website_nav_item_id',
                                            value:record.data.websiteNavItemId
                                        }
                                        ]
                                    }),
                                    buttons: [{
                                        text:'Submit',
                                        listeners:{
                                            'click':function(button){
                                                var window = button.findParentByType('window');
                                                var formPanel = window.query('form')[0];
                                                self.setWindowStatus('Updating menu item...');
                                                formPanel.getForm().submit({
                                                    reset:false,
                                                    success:function(form, action){
                                                        self.clearWindowStatus();
                                                        var obj = Ext.decode(action.response.responseText);
                                                        if(obj.success){
                                                            record.data.linkedToId = obj.linkedToId;
                                                            record.data.linkToType = obj.linkToType;
                                                            record.data.url = obj.url;
                                                        //node.getUI().getTextEl().innerHTML = obj.title;
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
                                                            var obj = Ext.decode(action.response.responseText);
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
                                            url: '/knitkit/erp_app/desktop/website_nav/delete_menu_item',
                                            method: 'POST',
                                            params:{
                                                id:record.data.websiteNavItemId
                                            },
                                            success: function(response) {
                                                self.clearWindowStatus();
                                                var obj = Ext.decode(response.responseText);
                                                if(obj.success){
                                                    record.remove(true);
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
                    var contextMenu = Ext.create("Ext.menu.Menu",{
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
                        var addWebsiteWindow = Ext.create("Ext.window.Window",{
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
                                url:'/knitkit/erp_app/desktop/site/new',
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
                                        var formPanel = window.query('.form')[0];
                                        self.setWindowStatus('Creating website...');
                                        formPanel.getForm().submit({
                                            success:function(form, action){
                                                self.clearWindowStatus();
                                                var obj = Ext.decode(action.response.responseText);
                                                if(obj.success){
                                                    self.sitesTree.getStore().load();
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
                        var importWebsiteWindow = Ext.create("Ext.window.Window",{
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
                                url:'/knitkit/erp_app/desktop/site/import',
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
                                        var formPanel = window.query('form')[0];
                                        self.setWindowStatus('Importing website...');
                                        formPanel.getForm().submit({
                                            success:function(form, action){
                                                self.clearWindowStatus();
                                                var obj =  Ext.decode(action.response.responseText);
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
                                                var obj =  Ext.decode(action.response.responseText);
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
        var xtype = 'knitkit_'+node.data.type.toLowerCase()+'articlesgridpanel';
        this.contentsCardPanel.add({
            xtype:xtype,
            title:node.data.siteName + ' - ' + node.data.text + ' - Articles',
            sectionId:node.data.id.split('_')[1],
            centerRegion:this.initialConfig['module'].centerRegion,
            siteId:node.data.siteId
        });
        this.contentsCardPanel.getLayout().setActiveItem(this.contentsCardPanel.items.length - 1);
    },

    getPublications : function(node){
        this.contentsCardPanel.removeAll(true);
        this.contentsCardPanel.add({
            xtype:'knitkit_publishedgridpanel',
            title:node.data.siteName + ' Publications',
            siteId:node.data.id.split('_')[1],
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
