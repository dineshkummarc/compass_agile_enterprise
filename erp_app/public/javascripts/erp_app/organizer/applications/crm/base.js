Ext.define("Compass.ErpApp.Organizer.Applications.Crm.Layout",{
    extend:"Ext.panel.Panel",
    alias:'widget.contactslayout',
    //private member partyId
    partyId:null,
    widget_xtypes:null,

    expandContacts : function(){
        this.southPanel.expand(true);
    },

    constructor : function(config) {
        this.southPanel = new Ext.Panel({
            layout:'fit',
            region:'south',
            height:300,
            collapsible:true,
            collapsed:true,
            border:false,
            items:[config['southComponent']]
        });

        var centerPanel = new Ext.Panel({
            layout:'fit',
            region:'center',
            autoScroll:true,
            items:[config['centerComponent']]
        });
        this.widget_xtypes = config.widget_xtypes;

        config = Ext.apply({
            layout:'border',
            frame: false,
            autoScroll:true,
            region:'center',
            items:[
            centerPanel,
            this.southPanel
            ]

        }, config);

        this.callParent([config]);
    },

    /**
     * set the private member partyId
     * @param {Integer} partyId id to set member partyId to
     */
    setPartyId : function(partyId){
        this.partyId = partyId;
    },

    /**
     * load details of party
     */
    loadPartyDetails : function(){
        if(this.partyId == null){
            Ext.Msg.alert('Error', 'Member partyId not set');
        }
        else{
            var tabPanel = this.query('tabpanel')[0];

            for (i=0; i < this.widget_xtypes.length; i++) {
                var widget = tabPanel.query(this.widget_xtypes[i]);
                if(widget.length > 0) {
                    widget[0].setParams({partyId: this.partyId});
                    widget[0].store.load();
                }
            }

            this.query('tabpanel')[0].setActiveTab(0);
        }
    }

});

Compass.ErpApp.Organizer.Applications.Crm.Base = function(config){
    
    var addIndividualWindow = Ext.create("Ext.window.Window",{
        layout:'fit',
        width:375,
        title:'New Individual',
        height:500,
        buttonAlign:'center',
        items: new Ext.FormPanel({
            labelWidth: 110,
            frame:false,
            bodyStyle:'padding:5px 5px 0',
            width: 425,
            url:'./crm/create_party',
            defaults: {
                width: 225
            },
            items: [
            {
                xtype:'textfield',
                fieldLabel:'Enterprise Identifier',
                allowBlank:true,
                name:'enterprise_identifier'
            },
            {
                xtype:'textfield',
                fieldLabel:'Suffix',
                allowBlank:true,
                name:'current_suffix'
            },
            {
                xtype:'textfield',
                fieldLabel:'Title',
                allowBlank:true,
                name:'current_personal_title'
            },
            {
                xtype:'textfield',
                fieldLabel:'First Name',
                allowBlank:false,
                name:'current_first_name'
            },
            {
                xtype:'textfield',
                fieldLabel:'Middle Name',
                allowBlank:true,
                name:'current_middle_name'
            },
            {
                xtype:'textfield',
                fieldLabel:'Last Name',
                allowBlank:false,
                name:'current_last_name'
            },
            {
                xtype:'textfield',
                fieldLabel:'Nickname',
                allowBlank:true,
                name:'current_nickname'
            },
            {
                xtype:'textfield',
                fieldLabel:'Passport Number',
                allowBlank:true,
                name:'current_passport_number'
            },
            {
                xtype:'datefield',
                fieldLabel:'Passport Expiration Date',
                allowBlank:true,
                name:'current_passport_expire_date'
            },
            {
                xtype:'datefield',
                fieldLabel:'DOB',
                allowBlank:false,
                name:'birth_date'
            },
            {
                xtype:'textfield',
                fieldLabel:'Gender',
                allowBlank:false,
                name:'gender'
            },
            {
                xtype:'textfield',
                fieldLabel:'Total Yrs Work Exp',
                allowBlank:true,
                name:'total_years_work_experience'
            },
            {
                xtype:'textfield',
                fieldLabel:'Marital Status',
                allowBlank:true,
                name:'marital_status'
            },
            {
                xtype:'textfield',
                fieldLabel:'Social Security Number',
                allowBlank:true,
                name:'social_security_number'
            }
            ]
        }),
        buttons: [{
            text:'Submit',
            listeners:{
                'click':function(button){
                    var window = button.findParentByType('window');
                    var formPanel = window.query('form')[0];
                    formPanel.getForm().submit({
                        reset:true,
                        params:{
                            party_type:'Individual'
                        },
                        waitMsg:'Creating Individual',
                        success:function(form, action){
                            var response =  Ext.decode(action.response.responseText);
                            Ext.Msg.alert("Status", response.message);
                            if(response.success){
                                var individualName = response.individualName;
                                addIndividualWindow.hide();
                                var individualsSearchGrid = Ext.ComponentMgr.get('individualSearchGrid');
                                individualsSearchGrid.store.proxy.extraParams.party_name = individualName;
                                individualsSearchGrid.store.load();
                            }
                        },
                        failure:function(form, action){
                            var message = 'Error adding individual';
                            if(action.response != null){
                                var response =  Ext.decode(action.response.responseText);
                                message = response.message;
                            }
                            Ext.Msg.alert("Status", message);
                        }
                    });
                }
            }
        },{
            text: 'Close',
            handler: function(){
                addIndividualWindow.hide();
            }
        }]
    });

    var addOrganizationWindow = Ext.create("Ext.window.Window",{
        layout:'fit',
        width:375,
        title:'New Organization',
        height:160,
        buttonAlign:'center',
        items: new Ext.FormPanel({
            labelWidth: 110,
            frame:false,
            bodyStyle:'padding:5px 5px 0',
            width: 425,
            url:'./crm/create_party',
            defaults: {
                width: 225
            },
            items: [
            {
                xtype:'textfield',
                fieldLabel:'Enterprise Identifier',
                allowBlank:true,
                name:'enterprise_identifier'
            },
            {
                xtype:'textfield',
                fieldLabel:'Tax ID',
                allowBlank:true,
                name:'tax_id_number'
            },
            {
                xtype:'textfield',
                fieldLabel:'Description',
                allowBlank:true,
                name:'description'
            }
            ]
        }),
        buttons: [{
            text:'Submit',
            listeners:{
                'click':function(button){
                    var window = button.findParentByType('window');
                    var formPanel = window.query('form')[0];
                    formPanel.getForm().submit({
                        reset:true,
                        waitMsg:'Creating Organization',
                        params:{
                            party_type:'Organization'
                        },
                        success:function(form, action){
                            var response =  Ext.decode(action.response.responseText);
                            Ext.Msg.alert("Status", response.message);
                            if(response.success){
                                var organizationName = response.organizationName;
                                addOrganizationWindow.hide();
                                var organizationSearchGrid = Ext.ComponentMgr.get('organizationSearchGrid');
                                organizationSearchGrid.store.proxy.extraParams.party_name = organizationName;
                                organizationSearchGrid.store.load();
                            }
                        },
                        failure:function(form, action){
                            var message = "Error adding organization";
                            if(action.response != null){
                                var response =  Ext.decode(action.response.responseText);
                                message = response.message;
                            }
                            Ext.Msg.alert("Status", message);
                        }
                    });
                }
            }
        },{
            text: 'Close',
            handler: function(){
                addOrganizationWindow.hide();
            }
        }]
    });

    var treeMenuStore = Ext.create('Compass.ErpApp.Organizer.DefaultMenuTreeStore', {
        url:'./crm/menu',
        rootText:'Customers',
        rootIconCls:'icon-content',
        additionalFields:[
        {
            name:'businessPartType'
        }
        ]
    });

    var menuTreePanel = {
        xtype:'defaultmenutree',
        title:'CRM',
        store:treeMenuStore,
        listeners:{
            scope:this,
            'itemcontextmenu':function(view, record, htmlItem, index, e){
                e.stopEvent();
                if(record.isLeaf()){
                    var contextMenu = null;
                    if(record.data.businessPartType == "individual"){
                        contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:"Add Individual",
                                iconCls:'icon-add',
                                listeners:{
                                    'click':function(){
                                        addIndividualWindow.show();
                                    }
                                }
                            }
                            ]
                        });
                    }
                    else
                    if(record.data.businessPartType == "organization"){
                        contextMenu = new Ext.menu.Menu({
                            items:[
                            {
                                text:"Add Organization",
                                iconCls:'icon-add',
                                listeners:{
                                    'click':function(){
                                        addOrganizationWindow.show();
                                    }
                                }
                            }
                            ]
                        });
                    }
                    contextMenu.showAt(e.xy);
                }
            }
        }
    };

    var individualsGrid = {
        id:'individualSearchGrid',
        xtype:'partygrid',
        partyType:'Individual',
        listeners:{
            'addpartybtnclick':function(btn, grid){
                addIndividualWindow.show();
            },
            'itemclick':function(view, record, item, index, e, options){
                var id = record.get("id");
                var contactsLayoutPanel = view.findParentByType('contactslayout');
                contactsLayoutPanel.expandContacts();
                contactsLayoutPanel.setPartyId(id);
                contactsLayoutPanel.loadPartyDetails();
            }
        }
    };

    var organizationsGrid = {
        id:'organizationSearchGrid',
        xtype:'partygrid',
        partyType:'Organization',
        listeners:{
            'addpartybtnclick':function(btn, grid){
                addOrganizationWindow.show();
            },
            'itemclick':function(view, record, item, index, e, options){
                var id = record.get("id");
                var contactsLayoutPanel = view.findParentByType('contactslayout');
                contactsLayoutPanel.expandContacts();
                contactsLayoutPanel.setPartyId(id);
                contactsLayoutPanel.loadPartyDetails();
            }
        }
    };

    var contactPurposeStore = Ext.create('Ext.data.Store', {
        autoLoad:true,
        proxy: {
            type: 'ajax',
            url : './crm/contact_purposes',
            reader: {
                type: 'json',
                root: 'types'
            }
        },
        fields:[
        {
            name: 'description'
        },
        {
            name: 'id'
        }
        ]
    });

    var individualsPanelSouthItems = [];

    var xtypes = ErpApp.Authentication.RoleManager.findValidWidgets(config.widget_roles,
        {partygrid : true});

    for (var i = 0; i < xtypes.length; i++) {
        individualsPanelSouthItems.push({
            xtype: xtypes[i],
            contactPurposeStore:contactPurposeStore
        });
    }

    var individualsPanel = {
        xtype:'contactslayout',
        id:'individuals_search_grid',
        widget_xtypes: xtypes,
        southComponent:{
            xtype:'tabpanel',
            id:'individualsTabPanel',
            items:individualsPanelSouthItems
        },
        centerComponent:individualsGrid
    };

    var organizationsPanelSouthItems = [];

    for (i = 0; i < xtypes.length; i++) {
        organizationsPanelSouthItems.push({
            xtype: xtypes[i]
        });
    }


    var organizationsPanel = {
        xtype:'contactslayout',
        id:'organizations_search_grid',
        widget_xtypes: xtypes,
        southComponent:{
            xtype:'tabpanel',
            id:'organizationTabPanel',
            items:organizationsPanelSouthItems
        },
        centerComponent:organizationsGrid
    };

    this.setup = function(){
        config['organizerLayout'].addApplication(menuTreePanel, [individualsPanel, organizationsPanel]);
    };
    
};

