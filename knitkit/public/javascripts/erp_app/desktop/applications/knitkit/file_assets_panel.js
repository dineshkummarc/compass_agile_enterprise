Compass.ErpApp.Desktop.Applications.Knitkit.FileAssetsPanel = function(module) {
    this.websiteId = null;
    var self = this;
    self.module = module;
			
  this.changeSecurityOnFile = function(node, secure, model, websiteId){
    var msg = secure ? 'Securing file...' : 'Unsecuring file...';
    var waitMsg = Ext.Msg.wait("Please Wait", msg);
    Ext.Ajax.request({
      url: '/knitkit/erp_app/desktop/file_assets/'+model+'/update_security',
      method: 'POST',
      params:{
        path:node.get('id'),
        secure:secure,
        website_id:websiteId
      },
      success: function(response) {
        var obj = Ext.decode(response.responseText);
        if(obj.success){
          waitMsg.hide();
          if(secure){
            node.set('iconCls', 'icon-document_lock');
          }
          else{
            node.set('iconCls', 'icon-document');
          }
          node.set('isSecured',secure);
          node.commit();
        }
        else{
          Ext.Msg.alert('Error', 'Error securing file.');
        }
      },
      failure: function(response) {
        waitMsg.hide();
        Ext.Msg.alert('Error', 'Error securing file.');
      }
    });
  };

  this.sharedFileAssetsTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
    title:'Shared',
    allowDownload:false,
    addViewContentsToContextMenu:false,
    rootVisible:true,
    controllerPath:'/knitkit/erp_app/desktop/file_assets/shared',
    standardUploadUrl:'/knitkit/erp_app/desktop/file_assets/shared/upload_file',
    xhrUploadUrl:'/knitkit/erp_app/desktop/file_assets/shared/upload_file',
    url:'/knitkit/erp_app/desktop/file_assets/shared/expand_directory',
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
              self.module.centerRegion.insertHtmlIntoActiveCkEditor('<a href="#" onclick="window.open(\'/knitkit/erp_app/desktop/file_assets/shared/download_file_asset?path='+node.data.downloadPath+'\',\'mywindow\',\'width=400,height=200\');return false;">'+text+'</a>');
            }
          });
        }
      }
    },
    {
      nodeType:'leaf',
      text:'Update Security',
      iconCls:'icon-document_lock',
      listeners:{
        scope:self,
        'click':function(){
          var node = this.sharedFileAssetsTreePanel.selectedNode;
          self.changeSecurityOnFile(node, !node.get('isSecured'), 'shared');
        }
      }
    }],
    listeners:{
      'allowdelete':function(){
         return currentUser.hasApplicationCapability('knitkit', {
         capability_type_iid:'delete',
         resource:'GlobalFileAsset'
       });
    },
      'allowupload':function(){
        return currentUser.hasApplicationCapability('knitkit', {
        capability_type_iid:'upload',
        resource:'GlobalFileAsset'
      });
    },
      'itemclick':function(view, record, item, index, e){
        e.stopEvent();
        return false;
      },
      'fileDeleted':function(fileTreePanel, node){},
      'fileUploaded':function(fileTreePanel, node){},
      'downloadfile':function(fileTreePanel, node){
        window.open("/knitkit/erp_app/desktop/file_assets/shared/download_file_asset/?path=" + node.data.id,'mywindow','width=400,height=200');
        return false;
      }
    }
  });

  this.websiteFileAssetsTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
    autoLoadRoot:false,
    title:'Website',
    allowDownload:false,
    addViewContentsToContextMenu:false,
    rootVisible:true,
    controllerPath:'/knitkit/erp_app/desktop/file_assets/website',
    standardUploadUrl:'/knitkit/erp_app/desktop/file_assets/website/upload_file',
    xhrUploadUrl:'/knitkit/erp_app/desktop/file_assets/website/upload_file',
    url:'/knitkit/erp_app/desktop/file_assets/website/expand_directory',
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
              self.module.centerRegion.insertHtmlIntoActiveCkEditor('<a href="#" onclick="window.open(\'/knitkit/erp_app/desktop/file_assets/website/download_file_asset?website_id='+self.websiteId+'&path='+node.data.downloadPath+'\',\'mywindow\',\'width=400,height=200\');return false;">'+text+'</a>');
            }
          });
        }
      }
    },
    {
      nodeType:'leaf',
      text:'Update Security',
      iconCls:'icon-document_lock',
      listeners:{
        scope:self,
        'click':function(){
          var node = this.websiteFileAssetsTreePanel.selectedNode;
          self.changeSecurityOnFile(node, !node.get('isSecured'), 'website', this.websiteId);
        }
      }
    }],
    listeners:{
      scope:self,
      'show': function(){
        self.reloadWebsiteFileAssetsTreePanel(self.websiteId);
      },
      'itemclick':function(view, record, item, index, e){
        e.stopEvent();
        return false;
      },
      'fileDeleted':function(fileTreePanel, node){},
      'fileUploaded':function(fileTreePanel, node){},
      'downloadfile':function(fileTreePanel, node){
        window.open("/knitkit/erp_app/desktop/file_assets/website/download_file_asset/?website_id="+self.websiteId+"&path=" + node.data.id,'mywindow','width=400,height=200');
        return false;
      }
    }
  });
  
  var items = [];

    if (currentUser.hasApplicationCapability('knitkit', {
        capability_type_iid:'view',
        resource:'GlobalFileAsset'
    }))

    {
        items.push(this.sharedFileAssetsTreePanel);
    }

    if (currentUser.hasApplicationCapability('knitkit', {
        capability_type_iid:'view',
        resource:'SiteFileAsset'
    }))

    {
        items.push(this.websiteFileAssetsTreePanel);
    }
  
  this.layout = Ext.create('Ext.panel.Panel',{
    layout: 'fit',
    title:'Files',
    items: Ext.create('Ext.tab.Panel',{
      items:items
    })
  });

  this.selectWebsite = function(websiteId){
    this.websiteId = websiteId;
  }

  this.reloadWebsiteFileAssetsTreePanel = function(websiteId){
    this.websiteFileAssetsTreePanel.extraPostData = {
      website_id:websiteId
    };
    this.websiteFileAssetsTreePanel.getStore().setProxy({
      type: 'ajax',
      url:'/knitkit/erp_app/desktop/file_assets/website/expand_directory',
      extraParams:{
        website_id:websiteId
      }
    });
    this.websiteFileAssetsTreePanel.getStore().load();
  }
}
