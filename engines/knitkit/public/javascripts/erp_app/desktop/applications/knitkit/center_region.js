Compass.ErpApp.Desktop.Applications.Knitkit.CenterRegion = Ext.extend(Ext.Panel, {
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    viewSectionLayout : function(title, template){
        this.workArea.add({
            title:title + ' - Layout',
            disableToolbar:true,
            xtype:'codemirror',
            parser:'erb',
            sourceCode:template,
            closable:true
        });
        this.workArea.setActiveTab(this.workArea.items.length - 1);
        return false;
    },

    saveSectionLayout : function(sectionId, content){
        var self = this;
        this.setWindowStatus('Saving...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/section/save_layout',
            method: 'POST',
            params:{
                id:sectionId,
                content:content
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.clearWindowStatus();
                }
                else{
                    Ext.Msg.alert('Error', 'Error saving layout');
                    self.clearWindowStatus();
                }
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error saving layout');
            }
        });
    },

    editSectionLayout : function(sectionName, websiteId, websiteSectionId, content, tbarItems){
        var self = this;

        var centerRegionLayout = new Ext.Panel({
            layout:'border',
            title:sectionName,
            closable:true,
            items:[
            {
                title:sectionName + ' - Layout',
                tbarItems:tbarItems,
                xtype:'codemirror',
                parser:'erb',
                region:'center',
                sourceCode:content,
                closable:true,
                listeners:{
                    'save':function(codeMirror, content){
                        self.saveSectionLayout(websiteSectionId, content);
                    }
                }
            },
            {
                xtype:'knitkit_versionswebsitesectiongridpanel',
                websiteSectionId:websiteSectionId,
                region:'south',
                height:300,
                collapsible:true,
                centerRegion:self,
                siteId:websiteId
            }
            ]
        })


        this.workArea.add(centerRegionLayout);
        this.workArea.setActiveTab(this.workArea.items.length - 1);
        return false;
    },

    saveTemplateFile : function(path, content){
        var self = this;
        this.setWindowStatus('Saving...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './file_manager/base/update_file',
            method: 'POST',
            params:{
                node:path,
                content:content
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.clearWindowStatus();
                }
                else{
                    Ext.Msg.alert('Error', 'Error saving contents');
                    self.clearWindowStatus();
                }
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error saving contents');
            }
        });
    },

    editTemplateFile : function(node, content, tbarItems){
        var self = this;
        var file_name = node.id.split('/').pop().split('.')[0];
        var fileType = node.id.split('.').pop();
        this.workArea.add({
            title:file_name,
            tbarItems:tbarItems,
            xtype:'codemirror',
            parser:fileType,
            sourceCode:content,
            closable:true,
            listeners:{
                'save':function(codeMirror, content){
                    self.saveTemplateFile(node.id, content);
                }
            }
        });
        this.workArea.setActiveTab(this.workArea.items.length - 1);
        return false;
    },

    saveExcerpt : function(id, content){
        var self = this;
        this.setWindowStatus('Saving...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/content/save_excerpt',
            method: 'POST',
            params:{
                id:id,
                html:content
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.clearWindowStatus();
                    var activeTab = self.workArea.getActiveTab();
                    activeTab.findByType('knitkit_versionsbloggridpanel')[0].getStore().reload();
                }
                else{
                    Ext.Msg.alert('Error', 'Error saving excerpt');
                    self.clearWindowStatus();
                }
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error saving excerpt');
            }
        });
    },

    editExcerpt : function(title, id, content, siteId){
        var self = this;
        var ckEditor = new Compass.ErpApp.Shared.CKeditor({
            autoHeight:true,
            value:content,
            ckEditorConfig:{
                toolbar:[
                ['Source','-','compasssave','Preview','-','Templates'],
                ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
                ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
                ['Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField'],
                '/',
                ['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
                ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote','CreateDiv'],
                ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
                ['BidiLtr', 'BidiRtl' ],
                ['Link','Unlink','Anchor'],
                ['Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak','Iframe'],
                '/',
                ['Styles','Format','Font','FontSize'],
                ['TextColor','BGColor'],
                ['Maximize', 'ShowBlocks','-','About']
                ]
            },
            listeners:{
                'save':function(ckEditor, content){
                    self.saveExcerpt(id, content)
                }
            }
        });

        var centerRegionLayout = new Ext.Panel({
            layout:'border',
            title:title,
            closable:true,
            items:[
            {
                xtype:'panel',
                layout:'fit',
                split:true,
                region:'center',
                items:ckEditor,
                autoDestroy:true
            },
            {
                xtype:'knitkit_versionsbloggridpanel',
                contentId:id,
                region:'south',
                height:300,
                collapsible:true,
                centerRegion:self,
                siteId:siteId
            }
            ]
        })

        this.workArea.add(centerRegionLayout);
        this.workArea.setActiveTab(this.workArea.items.length - 1);
    },

    saveContent : function(id, content, contentType){
        var self = this;
        this.setWindowStatus('Saving...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/content/update',
            method: 'POST',
            params:{
                id:id,
                html:content
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.clearWindowStatus();
                    var activeTab = self.workArea.getActiveTab();
                    activeTab.findByType('knitkit_versions'+contentType+'gridpanel')[0].getStore().reload();;
                }
                else{
                    Ext.Msg.alert('Error', 'Error saving contents');
                    self.clearWindowStatus();
                }
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error saving contents');
            }
        });
    },

    viewContent : function(title, content){
        var ckEditor = new Compass.ErpApp.Shared.CKeditor({
            autoHeight:true,
            value:content,
            ckEditorConfig:{
                toolbar:[['Preview']]
            }
        });

        this.workArea.add({
            xtype:'panel',
            closable:true,
            layout:'fit',
            title:title,
            split:true,
            items:ckEditor,
            autoDestroy:true
        });
        this.workArea.setActiveTab(this.workArea.items.length - 1);
    },

    editContent : function(title, id, content, siteId, contentType){
        var self = this;
        var ckEditor = new Compass.ErpApp.Shared.CKeditor({
            autoHeight:true,
            value:content,
            ckEditorConfig:{
                toolbar:[
                ['Source','-','compasssave','Preview','-','Templates'],
                ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
                ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
                ['Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField'],
                '/',
                ['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
                ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote','CreateDiv'],
                ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
                ['BidiLtr', 'BidiRtl' ],
                ['Link','Unlink','Anchor'],
                ['Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak','Iframe'],
                '/',
                ['Styles','Format','Font','FontSize'],
                ['TextColor','BGColor'],
                ['Maximize', 'ShowBlocks','-','About']
                ]
            },
            listeners:{
                'save':function(ckEditor, content){
                    self.saveContent(id, content, contentType)
                }
            }
        });

        var centerRegionLayout = new Ext.Panel({
            layout:'border',
            title:title,
            closable:true,
            items:[
            {
                xtype:'panel',
                layout:'fit',
                split:true,
                region:'center',
                items:ckEditor,
                autoDestroy:true
            },
            {
                xtype:'knitkit_versions'+contentType+'gridpanel',
                contentId:id,
                region:'south',
                height:300,
                collapsible:true,
                centerRegion:self,
                siteId:siteId
            }
            ]
        })

        this.workArea.add(centerRegionLayout);
        this.workArea.setActiveTab(this.workArea.items.length - 1);
    },

    showComment : function(comment){
        var activeTab = this.workArea.getActiveTab();
        var cardPanel = activeTab.findByType('panel')[0];
        cardPanel.removeAll(true);
        cardPanel.add({
            disableToolbar:true,
            xtype:'codemirror',
            parser:'dummy',
            sourceCode:comment
        });
        cardPanel.getLayout().setActiveItem(0);
    },

    viewContentComments : function(contentId, title){
        var self = this;
        var centerRegionLayout = new Ext.Panel({
            layout:'border',
            title:title,
            closable:true,
            items:[
            {
                xtype:'panel',
                layout:'card',
                split:true,
                region:'center',
                items:[],
                autoDestroy:true
            },
            {
                xtype:'knitkit_commentsgridpanel',
                contentId:contentId,
                region:'south',
                height:300,
                collapsible:true,
                centerRegion:self
            }
            ]
        })

        this.workArea.add(centerRegionLayout);
        this.workArea.setActiveTab(this.workArea.items.length - 1);
    },

    viewWebsiteInquiries : function(websiteId, title){
        var self = this;
        var centerRegionLayout = new Ext.Panel({
            layout:'border',
            title:title,
            closable:true,
            items:[
            {
                xtype:'panel',
                layout:'card',
                split:true,
                region:'center',
                items:[],
                autoDestroy:true
            },
            {
                xtype:'knitkit_inquiriesgridpanel',
                websiteId:websiteId,
                region:'south',
                height:300,
                collapsible:true,
                centerRegion:self
            }
            ]
        })

        this.workArea.add(centerRegionLayout);
        this.workArea.setActiveTab(this.workArea.items.length - 1);
    },

    insertHtmlIntoActiveCkEditor : function(html){
        var activeTab = this.workArea.getActiveTab();
        if(Compass.ErpApp.Utility.isBlank(activeTab)){
            Ext.Msg.alert('Error', 'No editor');
        }
        else{
            if(activeTab.findByType('ckeditor').length == 0){
                Ext.Msg.alert('Error', 'No ckeditor found');
            }
            else{
                activeTab.findByType('ckeditor')[0].insertHtml(html);
            }
        }
        return false;
    },

    replaceHtmlInActiveCkEditor : function(html){
        var activeTab = this.workArea.getActiveTab();
        if(Compass.ErpApp.Utility.isBlank(activeTab)){
            Ext.Msg.alert('Error', 'No editor');
        }
        else{
            if(activeTab.findByType('ckeditor').length == 0){
                Ext.Msg.alert('Error', 'No ckeditor found');
            }
            else{
                activeTab.findByType('ckeditor')[0].setValue(html);
            }
        }
        return false;
    },

    replaceContentInActiveCodeMirror : function(content){
        var activeTab = this.workArea.getActiveTab();
        if(Compass.ErpApp.Utility.isBlank(activeTab)){
            Ext.Msg.alert('Error', 'No editor');
        }
        else{
            if(activeTab.findByType('codemirror').length == 0){
                Ext.Msg.alert('Error', 'No codemirror found');
            }
            else{
                activeTab.findByType('codemirror')[0].setValue(content);
            }
        }
        return false;
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.CenterRegion.superclass.initComponent.call(this, arguments);
    },
  
    constructor : function(config) {
        this.workArea = new Ext.TabPanel({
            autoDestroy:true,
            region:'center'
        });
        
        config = Ext.apply({
            autoDestroy:true,
            layout:'border',
            region:'center',
            split:true,
            items:[this.workArea]
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.CenterRegion.superclass.constructor.call(this, config);
    }
});

Ext.reg('knitkit_centerregion', Compass.ErpApp.Desktop.Applications.Knitkit.CenterRegion);
