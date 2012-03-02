Ext.define("Compass.ErpApp.Desktop.Applications.UserManagement.PersonalInfoPanel",{
  extend:"Ext.Panel",
  alias:'widget.usermanagement_personalinfopanel',
  setWindowStatus : function(status){
    this.findParentByType('statuswindow').setStatus(status);
  },
    
  clearWindowStatus : function(){
    this.findParentByType('statuswindow').clearStatus();
  },
  
  constructor : function(config) {
    var form;
    var userInformationFieldset = {
      xtype:'fieldset',
      width:400,
      title:'User Information',
      items:[
      {
        xtype:'displayfield',
        fieldLabel:'Username',
        labelWidth:'110',
        width:'150',
        value:config['userInfo']['username']
      },
      {
        xtype:'displayfield',
        fieldLabel:'Email Address',
        labelWidth:'110',
        width:'150',
        value:config['userInfo']['email']
      },
      {
        xtype:'displayfield',
        fieldLabel:'Activation State',
        labelWidth:'110',
        value:config['userInfo']['activation_state']
      },
      {
        xtype:'displayfield',
        fieldLabel:'Last Login',
        labelWidth:'110',
        value:Ext.util.Format.date(config['userInfo']['last_login_at'],'F j, Y, g:i a')
      },
      {
        xtype:'displayfield',
        fieldLabel:'Last Activity',
        labelWidth:'110',
        value:Ext.util.Format.date(config['userInfo']['last_activity_at'],'F j, Y, g:i a')
      },
      {
        xtype:'displayfield',
        labelWidth:'110',
        fieldLabel:'# Failed Logins',
        value:config['userInfo']['failed_login_count']
      }
      ]
    }

    if(config['entityType'] == 'Organization'){
      form = new Ext.FormPanel({
        frame:false,
        bodyStyle:'padding:5px 5px 0',
        width: 425,
        url:'/erp_app/desktop/contacts/create_party',
        items: [
        {
          xtype:'displayfield',
          width:400,
          title:config['entityType'] + ' Information',
          items:[
          {
            xtype:'textfield',
            labelWidth:'110',
            width:'150',
            fieldLabel:'Description',
            value:config['businessParty']['description']
          }
          ]
        },
        userInformationFieldset
        ]
      });
    }
    else{
      form = new Ext.FormPanel({
        frame:false,
        bodyStyle:'padding:5px 5px 0',
        width: 425,
        url:'/erp_app/desktop/contacts/create_party',
        items: [
        {
          xtype:'fieldset',
          width:400,
          title:config['entityType'] + ' Information',
          items:[
          {
            xtype:'displayfield',
            labelWidth:'110',
            width:'150',
            fieldLabel:'First Name',
            value:config['businessParty']['current_first_name']
          },
          {
            xtype:'displayfield',
            fieldLabel:'Last Name',
            labelWidth:'110',
            width:'150',
            value:config['businessParty']['current_last_name']
          },
          {
            xtype:'displayfield',
            fieldLabel:'Gender',
            labelWidth:'110',
            width:'150',
            value:config['businessParty']['gender']
          }
          ]
        },
        userInformationFieldset
        ]
      });
    }

    config = Ext.apply({
      items:[form],
      layout:'fit',
      title:'User Details'
    }, config);

    this.callParent([config]);
  }
});
