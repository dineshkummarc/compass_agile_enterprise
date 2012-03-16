Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsPanel = function() {
  var self = this;
  this.websiteId = null;
  this.sharedImageAssetsDataView = Ext.create("Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsDataView",{
    url: '/knitkit/erp_app/desktop/image_assets/shared/get_images'
  });
  this.websiteImageAssetsDataView = Ext.create("Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsDataView",{
    url: '/knitkit/erp_app/desktop/image_assets/website/get_images'
  });

  this.sharedImageAssetsTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
    region:'north',
    rootText:'Images',
    collapsible:true,
    allowDownload:false,
    addViewContentsToContextMenu:false,
    rootVisible:true,
    controllerPath:'/knitkit/erp_app/desktop/image_assets/shared',
    standardUploadUrl:'/knitkit/erp_app/desktop/image_assets/shared/upload_file',
    xhrUploadUrl:'/knitkit/erp_app/desktop/image_assets/shared/upload_file',
    url:'/knitkit/erp_app/desktop/image_assets/shared/expand_directory',
    containerScroll: true,
    height:200,
    listeners:{
           'allowdelete':function(){
                return currentUser.hasApplicationCapability('knitkit', {
                    capability_type_iid:'delete',
                    resource:'GlobalImageAsset'
                });
            },
            'allowupload':function(){
                return currentUser.hasApplicationCapability('knitkit', {
                    capability_type_iid:'upload',
                    resource:'GlobalImageAsset'
                });
            },
      'itemclick':function(view, record, item, index, e){
        e.stopEvent();
        if(!record.data["leaf"]){
          var store = self.sharedImageAssetsDataView.getStore();
          store.load({
            params:{
              directory:record.data.id
            }
          });
        }
        else{
          return false;
        }
      },
      'fileDeleted':function(fileTreePanel, node){
        var store = self.sharedImageAssetsDataView.getStore();
        store.load();
      },
      'fileUploaded':function(fileTreePanel, node){
        var store = self.sharedImageAssetsDataView.getStore();
        store.load();
      }
    }
  });

  this.websiteImageAssetsTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
    autoLoadRoot:false,
    region:'north',
    rootText:'Images',
    collapsible:true,
    allowDownload:false,
    addViewContentsToContextMenu:false,
    rootVisible:true,
    controllerPath:'/knitkit/erp_app/desktop/image_assets/website',
    standardUploadUrl:'/knitkit/erp_app/desktop/image_assets/website/upload_file',
    xhrUploadUrl:'/knitkit/erp_app/desktop/image_assets/website/upload_file',
    url:'/knitkit/erp_app/desktop/image_assets/website/expand_directory',
    containerScroll: true,
    height:200,
    listeners:{
      'itemclick':function(view, record, item, index, e){
        if(self.websiteId != null){
          e.stopEvent();
          if(!record.data["leaf"]){
            var store = self.websiteImageAssetsDataView.getStore();
            store.load({
              params:{
                directory:record.data.id,
                website_id:self.websiteId
              }
            });
          }
          else{
            return false;
          }
        }
      },
      'fileDeleted':function(fileTreePanel, node){
        self.websiteImageAssetsDataView.getStore().load({
          params:{
            directory:node.data.id,
            website_id:self.websiteId
          }
        });
      },
      'fileUploaded':function(fileTreePanel, node){
        self.websiteImageAssetsDataView.getStore().load({
          params:{
            directory:node.data.id,
            website_id:self.websiteId
          }
        });
      }
    }
  });

  var sharedImagesPanel = Ext.create('Ext.panel.Panel',{
    cls:'image-assets',
    region:'center',
    margins: '5 5 5 0',
    layout:'fit',
    items: this.sharedImageAssetsDataView
  });

  var websiteImagesPanel = Ext.create('Ext.panel.Panel',{
    cls:'image-assets',
    region:'center',
    margins: '5 5 5 0',
    layout:'fit',
    items: this.websiteImageAssetsDataView
  });

  var sharedImagesLayout =  Ext.create('Ext.panel.Panel',{
    layout: 'border',
    title:'Shared',
    items: [this.sharedImageAssetsTreePanel, sharedImagesPanel]
  });
	
  var websiteImagesLayout =  Ext.create('Ext.panel.Panel',{
    layout: 'border',
    title:'Website',
    items: [this.websiteImageAssetsTreePanel, websiteImagesPanel],
    listeners:{
      scope:self,
      'show': function(){
        self.reloadWebsiteImageAssetsTreePanel(self.websiteId);
      }       
    }
  });

 var items = [];
    if (currentUser.hasApplicationCapability('knitkit', {
        capability_type_iid:'view',
        resource:'GlobalImageAsset'
    }))

    {
        items.push(sharedImagesLayout);
    }

    if (currentUser.hasApplicationCapability('knitkit', {
        capability_type_iid:'view',
        resource:'SiteImageAsset'
    }))

    {
        items.push(websiteImagesLayout);
    }

  this.layout = Ext.create('Ext.panel.Panel',{
    layout:'fit',
    title:'Images',
    items: Ext.create('Ext.tab.Panel',{
      items: items
    })
  });

  this.selectWebsite = function(websiteId){
    this.websiteId = websiteId;
  }

  this.reloadWebsiteImageAssetsTreePanel = function(websiteId){
    this.websiteImageAssetsTreePanel.extraPostData = {
      website_id:websiteId,
      websiteid:websiteId // for xhrFileUpload to work      
    };
    var store = this.websiteImageAssetsTreePanel.getStore();
    store.load({
      params:{
        website_id:websiteId
      }
    });
    this.websiteImageAssetsDataView.getStore().removeAll();
  }
}
