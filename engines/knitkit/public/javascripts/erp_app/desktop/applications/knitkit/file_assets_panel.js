Compass.ErpApp.Desktop.Applications.Knitkit.FileAssetsPanel = function(module) {
  this.websiteId = null;
  var self = this;
  self.module = module;
			
  this.sharedFileAssetsTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
    //TODO_EXTJS4 this is added to fix error should be removed when extjs 4 releases fix.
    viewConfig:{
      loadMask: false
    },
    tbar:{
      items:[
      {
        text:'Sync',
        iconCls:'icon-recycle',
        handler:function(btn){
          var waitMsg = Ext.Msg.wait('Status...','Syncing');
          var conn = new Ext.data.Connection();
          conn.request({
            url: './knitkit/file_assets/shared/sync',
            method: 'POST',
            success: function(response) {
              waitMsg.hide();
              var responseObj =  Ext.decode(response.responseText);
              if(responseObj.success){
                self.sharedFileAssetsTreePanel.getStore().load();
                Ext.Msg.alert("Success", responseObj.message);
              }
              else{
                Ext.Msg.alert("Error", responseObj.message);
              }
            },
            failure: function(response) {
              waitMsg.hide();
              Ext.Msg.alert('Status', 'Error during sync.');
            }
          });
        }
      }
      ]
    },
    title:'Shared',
    allowDownload:false,
    addViewContentsToContextMenu:false,
    rootVisible:true,
    controllerPath:'./knitkit/file_assets/shared',
    standardUploadUrl:'./knitkit/file_assets/shared/upload_file',
    xhrUploadUrl:'./knitkit/file_assets/shared/upload_file',
    url:'./knitkit/file_assets/shared/expand_directory',
    containerScroll: true,
    additionalContextMenuItems:[{
      nodeType:'leaf',
      text:'Insert link at cursor',
      iconCls:'icon-add',
      listeners:{
        scope:self,
        'click':function(){
          var node = this.sharedFileAssetsTreePanel.selectedNode;
          Ext.MessageBox.prompt('Display Name', 'Please enter display name:', function(btn, text){
            if(btn == 'ok'){
              self.module.centerRegion.insertHtmlIntoActiveCkEditor('<a href="#" onclick="window.open(\'/erp_app/desktop/knitkit/file_assets/download_file_asset/?path='+node.data.downloadPath+'\',\'mywindow\',\'width=400,height=200\');return false;">'+text+'</a>');
            }
          });
        }
      }
    }],
    listeners:{
      'itemclick':function(view, record, item, index, e){
        e.stopEvent();
        return false;
      },
      'fileDeleted':function(fileTreePanel, node){},
      'fileUploaded':function(fileTreePanel, node){}
    }
  });

  this.websiteFileAssetsTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
    //TODO_EXTJS4 this is added to fix error should be removed when extjs 4 releases fix.
    viewConfig:{
      loadMask: false
    },
    tbar:{
      items:[
      {
        text:'Sync',
        iconCls:'icon-recycle',
        handler:function(btn){
          var waitMsg = Ext.Msg.wait('Status...','Syncing');
          var conn = new Ext.data.Connection();
          conn.request({
            url: './knitkit/file_assets/website/sync',
            method: 'POST',
            params:{
              website_id:self.websiteId
            },
            success: function(response) {
              waitMsg.hide();
              var responseObj =  Ext.decode(response.responseText);
              if(responseObj.success){
                self.websiteFileAssetsTreePanel.getStore().load({
                  params:{
                    website_id:self.websiteId
                  }
                });
                Ext.Msg.alert("Success", responseObj.message);
              }
              else{
                Ext.Msg.alert("Error", responseObj.message);
              }
            },
            failure: function(response) {
              waitMsg.hide();
              Ext.Msg.alert('Status', 'Error during sync.');
            }
          });
        }
      }
      ]
    },
    title:'Website',
    allowDownload:false,
    addViewContentsToContextMenu:false,
    rootVisible:true,
    controllerPath:'./knitkit/file_assets/website',
    standardUploadUrl:'./knitkit/file_assets/website/upload_file',
    xhrUploadUrl:'./knitkit/file_assets/website/upload_file',
    url:'./knitkit/file_assets/website/expand_directory',
    containerScroll: true,
    additionalContextMenuItems:[{
      nodeType:'leaf',
      text:'Insert link at cursor',
      iconCls:'icon-add',
      listeners:{
        scope:self,
        'click':function(){
          var node = this.websiteFileAssetsTreePanel.selectedNode;
          Ext.MessageBox.prompt('Display Name', 'Please enter display name:', function(btn, text){
            if(btn == 'ok'){
              self.module.centerRegion.insertHtmlIntoActiveCkEditor('<a href="#" onclick="window.open(\'/erp_app/desktop/knitkit/file_assets/download_file_asset/?path='+node.data.downloadPath+'\',\'mywindow\',\'width=400,height=200\');return false;">'+text+'</a>');
            }
          });
        }
      }
    }],
    listeners:{
      'itemclick':function(view, record, item, index, e){
        e.stopEvent();
        return false;
      },
      'fileDeleted':function(fileTreePanel, node){},
      'fileUploaded':function(fileTreePanel, node){}
    }
  });
    
  this.layout = Ext.create('Ext.panel.Panel',{
    layout: 'fit',
    title:'Files',
    items: Ext.create('Ext.tab.Panel',{
      items:[this.sharedFileAssetsTreePanel, this.websiteFileAssetsTreePanel]
    })
  });

  this.selectWebsite = function(websiteId){
    this.websiteId = websiteId;
    this.websiteFileAssetsTreePanel.extraPostData = {
      website_id:websiteId
    };
    this.websiteFileAssetsTreePanel.getStore().setProxy({
      type: 'ajax',
      url:'./knitkit/file_assets/website/expand_directory',
      extraParams:{
        website_id:websiteId
      }
    });
    this.websiteFileAssetsTreePanel.getStore().load();
  }
}



