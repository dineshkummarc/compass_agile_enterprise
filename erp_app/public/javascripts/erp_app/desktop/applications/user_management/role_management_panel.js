Ext.define("Compass.ErpApp.Desktop.Applications.UserManagement.RoleManagementPanel",{
  extend:"Ext.Panel",
  alias:'widget.usermanagement_rolemanagementpanel',
  setWindowStatus : function(status){
    this.findParentByType('statuswindow').setStatus(status);
  },
    
  clearWindowStatus : function(){
    this.findParentByType('statuswindow').clearStatus();
  },

  addAllAvailableRoles : function(){
    var availableRolesRoot = this.availableRolesTree.getRootNode();
    var currentRolesRoot = this.currentRolesTree.getRootNode();

    availableRolesRoot.eachChild(function(node) {
      currentRolesRoot.appendChild(node.copy());
    });

    availableRolesRoot.removeAll(true);
  },

  removeAllCurrentRoles : function(){
    var availableRolesRoot = this.availableRolesTree.getRootNode();
    var currentRolesRoot = this.currentRolesTree.getRootNode();

    currentRolesRoot.eachChild(function(node) {
      availableRolesRoot.appendChild(node.copy());
    });

    currentRolesRoot.removeAll(true);
  },

  saveRoles : function(){
    var roleIds = []
    var treePanel = this.currentRolesTree;
    var treeRoot = treePanel.getRootNode();
    this.setWindowStatus('Saving...');

    treeRoot.eachChild(function(node) {
      roleIds.push(node.get('role_id'));
    });

    var rolesJson = {
      "role_ids[]":roleIds,
      "user_id":this.initialConfig['userId']
    };

    var self = this;
    Ext.Ajax.request({
      url: '/erp_app/desktop/user_management/role_management/save_roles',
      params:rolesJson,
      success: function(responseObject) {
        self.clearWindowStatus();
        if(self.initialConfig['userId'] == currentUser.id)
          Compass.ErpApp.Utility.promptReload();
      },
      failure: function() {
        self.clearWindowStatus();
        Ext.Msg.alert('Status', 'Unable To Save Roles. Please Try Agian Later.');
      }
    });

        
  },

  constructor : function(config) {
    var availableApplicationsStore = Ext.create('Ext.data.TreeStore', {
      proxy: {
        type: 'ajax',
        url: '/erp_app/desktop/user_management/role_management/available_roles',
        extraParams:{
          user_id:config['userId']
        }
      },
      root: {
        text: 'Available Roles',
        expanded: true
      },
      fields:[
      {
        name:'role_id'
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

    this.availableRolesTree = Ext.create("Ext.tree.TreePanel",{
      store:availableApplicationsStore,
      id:'role_mgt_available_roles',
      animate:false,
      autoDestroy:true,
      autoScroll:true,
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
      height: 300,
      frame:true,
      enableDrop:false,
      tbar:{
        items:[
        {
          text:'Add All',
          iconCls:'icon-add',
          scope:this,
          handler:function(){
            this.addAllAvailableRoles();
          }
        }
        ]
      }
    });

    var currentApplicationsStore = Ext.create('Ext.data.TreeStore', {
      proxy: {
        type: 'ajax',
        url:'/erp_app/desktop/user_management/role_management/current_roles',
        extraParams:{
          user_id:config['userId']
        }
      },
      root: {
        text: 'Current Roles',
        expanded: true
      },
      fields:[
      {
        name:'role_id'
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
        
    this.currentRolesTree = Ext.create("Ext.tree.TreePanel",{
      store:currentApplicationsStore,
      id:'role_mgt_current_roles',
      animate:false,
      autoDestroy:true,
      region:'center',
      autoScroll:true,
      tbar:{
        items:[
        {
          text:'Remove All',
          iconCls:'icon-delete',
          scope:this,
          handler:function(){
            this.removeAllCurrentRoles();
          }
        },
        {
          text:'Save',
          scope:this,
          iconCls:'icon-save',
          handler:function(){
            this.saveRoles();
          }
        }
        ]
      },
      containerScroll: true,
      border: false,
      frame:true,
      viewConfig: {
        plugins: {
          ptype: 'treeviewdragdrop',
          appendOnly: true
        }
      },
      width: 250,
      height: 300
    });

    config = Ext.apply({
      layout:'border',
      title:'Roles',
      autoDestroy:true,
      items:[this.availableRolesTree,this.currentRolesTree],
      buttonAlign:'left'
    }, config);


    this.callParent([config]);
  }
});
