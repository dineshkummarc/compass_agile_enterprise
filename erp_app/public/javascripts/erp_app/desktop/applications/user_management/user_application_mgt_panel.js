Ext.define("Compass.ErpApp.Desktop.Applications.UserManagement.UserApplicationMgtPanel",{
  extend:"Ext.Panel",
  alias:'widget.controlpanel_userapplicationmgtpanel',
  setWindowStatus : function(status){
    this.findParentByType('statuswindow').setStatus(status);
  },

  clearWindowStatus : function(){
    this.findParentByType('statuswindow').clearStatus();
  },

  addAllAvailableApplications : function(){
    var availableRolesRoot = this.available_applications_tree.getRootNode();
    var currentRolesRoot = this.current_applications_tree.getRootNode();

    availableRolesRoot.eachChild(function(node) {
      currentRolesRoot.appendChild(node.copy());
    });

    availableRolesRoot.removeAll(true);
  },

  removeAllCurrentApplications : function(){
    var availableRolesRoot = this.available_applications_tree.getRootNode();
    var currentRolesRoot = this.current_applications_tree.getRootNode();

    currentRolesRoot.eachChild(function(node) {
      availableRolesRoot.appendChild(node.copy());
    });

    currentRolesRoot.removeAll(true);
  },

  saveApplications : function(){
    var appIds = []
    var treePanel = this.current_applications_tree;
    var treeRoot = treePanel.getRootNode();
    this.setWindowStatus('Saving...');

    treeRoot.eachChild(function(node) {
      appIds.push(node.data.app_id);
    });

    var appsJson = {
      "app_ids":appIds,
      "app_container_type":this.initialConfig['appContainerType'],
      "user_id":this.initialConfig['userId']
    };

    var self = this;
    Ext.Ajax.request({
      url: '/erp_app/desktop/user_management/application_management/save_applications',
      method: 'PUT',
      jsonData:appsJson,
      success: function(responseObject) {
        self.clearWindowStatus();
        if(self.initialConfig['userId'] == currentUser.id)
          Compass.ErpApp.Utility.promptReload();
      },
      failure: function() {
        self.clearWindowStatus();
        Ext.Msg.alert('Status', 'Unable To Save Applications. Please Try Agian Later.');
      }
    });
  },

  constructor : function(config) {
    var availableApplicationsStore = Ext.create('Ext.data.TreeStore', {
      proxy: {
        type: 'ajax',
        url: '/erp_app/desktop/user_management/application_management/available_applications',
        extraParams:{
          user_id:config['userId'],
          app_container_type:config['appContainerType']
        }
      },
      root: {
        text: 'Available Applications',
        expanded: true
      },
      fields:[
      {
        name:'app_id'
      },
      {
        name:'text'
      },
      {
        name:'icon_cls'
      },
      {
        name:'is_leaf'
      }
      ]
    });

    this.available_applications_tree = new Ext.tree.TreePanel({
      store:availableApplicationsStore,
      animate:false,
      autoScroll:true,
      autoDestroy:true,
      region:'west',
      viewConfig: {
        plugins: {
          ptype: 'treeviewdragdrop',
          appendOnly: true
        }
      },
      containerScroll: true,
      border: false,
      width: 250,
      frame:true,
      tbar:{
        items:[
        {
          text:'Add All',
          iconCls:'icon-add',
          scope:this,
          handler:function(){
            this.addAllAvailableApplications();
          }
        }
        ]
      }
    });

    var currentApplicationsStore = Ext.create('Ext.data.TreeStore', {
      proxy: {
        type: 'ajax',
        url: '/erp_app/desktop/user_management/application_management/current_applications',
        extraParams:{
          user_id:config['userId'],
          app_container_type:config['appContainerType']
        }
      },
      root: {
        text: 'Current Applications',
        expanded: true
      },
      fields:[
      {
        name:'app_id'
      },
      {
        name:'text'
      },
      {
        name:'icon_cls'
      },
      {
        name:'is_leaf'
      }
      ]
    });

    this.current_applications_tree = new Ext.tree.TreePanel({
      store:currentApplicationsStore,
      animate:false,
      autoDestroy:true,
      region:'center',
      autoScroll:true,
      tbar:{
        items:[
        {
          text:'Remove All',
          loadMask:false,
          iconCls:'icon-delete',
          scope:this,
          handler:function(){
            this.removeAllCurrentApplications();
          }
        },
        {
          text:'Save',
          scope:this,
          iconCls:'icon-save',
          handler:function(){
            this.saveApplications();
          }
        }
        ]
      },
      viewConfig: {
        plugins: {
          ptype: 'treeviewdragdrop',
          appendOnly: true
        }
      },
      containerScroll: true,
      border: false,
      frame:true,
      width: 250
    });

    config = Ext.apply({
      layout:'border',
      items:[this.available_applications_tree,this.current_applications_tree],
      buttonAlign:'left',
      autoDestroy:true
    }, config);

    this.callParent([config]);
  }
});



