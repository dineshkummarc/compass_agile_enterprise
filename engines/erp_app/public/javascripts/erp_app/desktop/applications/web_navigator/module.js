Compass.ErpApp.Desktop.Applications.WebNavigator = Ext.extend(Ext.app.Module, {
    id:'web-navigator-win',

    updateUrl : function(button){
        var url = Ext.getCmp('web_navigator_textfield').getValue();
        var re = new RegExp('http://');
        if(url.match(re)){
            Ext.get('web_navigator_iframe').dom.src = url;
        }
        else{
            Ext.Msg.alert("Error", "Invaild web address must start with 'http://'")
        }
    },

    init : function(){
        this.launcher = {
            text: 'Web Navigator',
            iconCls:'icon-globe',
            handler : this.createWindow,
            scope: this
        }
    },

    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('web_navigator');
        if(!win){
            var tbarItems = [
            {
                xtype:'textfield',
                id:'web_navigator_textfield',
                width:500,
                value:'http://www.portablemind.com',
                listeners: {
                    specialkey:function(el, e){
                        if(e.getKey() == e.ENTER) {
                            self.updateUrl();
                        }
                    }
                }
            },
            {
                iconCls:'icon-next',
                text:'Go',
                handler:function(button){
                    self.updateUrl();
                }
            }];

            tbarItems.push({
                iconCls:'icon-monitor',
                text:'Organizer',
                handler:function(button){
                    Ext.get('web_navigator_iframe').dom.src = '../organizer/';
                }
            });
            tbarItems.push({
                iconCls:'icon-data',
                text:'RailsDbAdmin',
                handler:function(button){
                    Ext.get('web_navigator_iframe').dom.src = '../../rails_db_admin/base';
                }
            });

            if(!Compass.ErpApp.Utility.isBlank(this.initialConfig.toolBarButtons)){
                tbarItems = tbarItems.concat(this.initialConfig.toolBarButtons);
            }
            
            var self = this;
            win = desktop.createWindow({
                id: 'web_navigator',
                title:'Web Navigator',
                width:1000,
                height:800,
                iconCls: 'icon-globe',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout:'fit',
                items:[
                {
                    xtype:'panel',
                    layout:'fit',
                    tbar:{items:tbarItems,autoScroll:true},
                    html:'<iframe id="web_navigator_iframe" height="100%" width="100%" src="http://www.portablemind.com"></iframe>'
                }
                ]
            });
        }
        win.show();
    }
});


