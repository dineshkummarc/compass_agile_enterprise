Ext.define("Compass.ErpApp.Desktop.Applications.WebNavigator",{
    extend:"Ext.ux.desktop.Module",
    id:'web-navigator-win',
    iframeId:'web_navigator_iframe',
    urlHistory:[],
    historyPosition:0,

    goBack : function(){
        if (this.historyPosition > 0)
        {
            this.historyPosition--;
            Ext.get(this.iframeId).dom.src = this.urlHistory[this.historyPosition];
        }
        else
            Ext.Msg.alert('Error','You reached the first page of history');
    },

    goForward : function(){
        if (this.historyPosition < (this.urlHistory.length-1))
        {
            this.historyPosition++;
            Ext.get(this.iframeId).dom.src = this.urlHistory[this.historyPosition];
        }
        else
             Ext.Msg.alert('Error','You reached the last page of history');
    },

    gotToPage : function(url){
        this.urlHistory[this.urlHistory.length] = url;
        this.historyPosition = this.urlHistory.length - 1;
        Ext.get(this.iframeId).dom.src = url;
    },

    updateUrl : function(button){
        var url = Ext.getCmp('web_navigator_textfield').getValue();
        var re = new RegExp('http://');
        if(url.match(re)){
            this.gotToPage(url);
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

    createWindow : function(url){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('web_navigator');
        if(!win){
            if(Compass.ErpApp.Utility.isBlank(url) || typeof(url) != "string"){
                url = '/';
            }

            var tbarItems = [];
            tbarItems.push({
                iconCls:'icon-refresh',
                scope:this,
                handler:function(button){
                    Ext.get(this.iframeId).dom.contentDocument.location.reload(true);
                }
            });

            tbarItems.push("|");
            tbarItems.push({
                iconCls:'icon-monitor',
                text:'Organizer',
                scope:this,
                handler:function(button){
                    this.gotToPage('/erp_app/organizer/');
                }
            });
           
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
                    tbar:{
                        items:tbarItems,
                        autoScroll:true
                    },
                    html:'<iframe id="'+this.iframeId+'" height="100%" width="100%"></iframe>'
                }
                ]
            });
        }
        win.show();
        this.gotToPage(url);
        return win;
    }
});


