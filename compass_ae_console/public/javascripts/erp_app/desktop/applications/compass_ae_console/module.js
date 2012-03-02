//**************************************************
// Compass Desktop Console
//**************************************************
var desktop_console_history=new Array();
var desktop_console_history_index=0;
//----------------------------------
// add startsWith method to string
String.prototype.startsWith = function (str){
    return this.indexOf(str) == 0;
};
//---------------------------------
var startup_heading="<font color='goldenrod'><b>Compass Console Version 0.01</b>&nbsp;(<font color='white'>-help</font> for Help)</font><br>"
//---------------------------------
function sendCommand(destination,command){
    update_history_panel("<font color='white'>"+command+"</font>")
     
    if(command.startsWith("-clear")){
        clear_history_panel(startup_heading+"<br><hr>");
    }else{
     
    Ext.Ajax.request({
        url: '/compass_ae_console/erp_app/desktop/command',
        params: {
             
            command_message: command
        },
        success: function(response){
            var text = response.responseText;
            var result =Ext.JSON.decode(text)
            update_history_panel("<font color='yellow'>"+result.success+"</font>")
        }
    });
    }
}
//---------------------------------
function clear_history_panel(text){
    var panel=Ext.getCmp('console_history_panel');
    
    panel.update(""+text+"<br>");
                
    var d = panel.body.dom;
    d.scrollTop = d.scrollHeight - d.offsetHeight+10;
    panel.doLayout();
}
//---------------------------------
function update_history_panel(text){
    var panel=Ext.getCmp('console_history_panel');
    var old = panel.body.dom.innerHTML;
    panel.update(old+""+text+"<br>");
                
    var d = panel.body.dom;
    d.scrollTop = d.scrollHeight - d.offsetHeight+10;
    panel.doLayout();
}

//---------------------------------
var console_history_panel ={
    xtype: 'panel',
    id : 'console_history_panel',
    region: 'center',
    bodyStyle: "background-color:#000;",
    autoScroll:true,
    html : startup_heading
}

//---------------------------------

var console_text_area ={
    xtype: 'textarea',
    region : 'south',
    autoscroll: true,
    id: "console_text_area",
    enableKeyEvents: true,
    listeners: {
        afterrender: function(field) {
            field.focus();
          },
        // use key-up for textarea since ENTER does not affect focus traversal
        keyup: function(field, e){
            //console.log("textarea keyup:"+e);
            if (e.getKey() == e.ENTER){
                     
                sendCommand('console_text_area',field.getValue());
                // add to history 
                desktop_console_history[desktop_console_history.length]=field.getValue().substring(0,field.getValue().length-1);
                //update index
                desktop_console_history_index=desktop_console_history.length
                field.setValue("");
            }else if (e.getKey() == e.UP){
                     
                if(desktop_console_history.length==0){
                // no history to display
                }else{
                    desktop_console_history_index--;
                    if(desktop_console_history_index >=0){
                         
                    }
                    else{
                        desktop_console_history_index=desktop_console_history.length-1
                }
                    field.setValue(desktop_console_history[desktop_console_history_index]);    
                }
                   
            }else if (e.getKey() == e.DOWN){
                     
                if(desktop_console_history.length==0){
                // no history to display
                }else{
                    desktop_console_history_index++;
                    if(desktop_console_history_index >=(desktop_console_history.length)){
                         desktop_console_history_index=0
                    }
                    else{
                        //desktop_console_history_index=desktop_console_history.length-1
                }
                    field.setValue(desktop_console_history[desktop_console_history_index]);    
                }
            }
        }
    
    }
}
//---------------------------------
var console_panel={
    xtype: 'panel',
    layout: 'border',
    items :[ console_history_panel,console_text_area]
       
}

//---------------------------------

Ext.define("Compass.ErpApp.Desktop.Applications.CompassAeConsole",{
    extend:"Ext.ux.desktop.Module",
    id:'compass_console-win',
    init : function(){
        this.launcher = {
            text: 'Compass Console',
            iconCls:'icon-console',
            handler: this.createWindow,
            scope: this
        }
    },

    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('console');
        if(!win){
            win = desktop.createWindow({
                id: 'console',
                title:'Compass Console',
                width:1000,
                height:670,
                iconCls: 'console_icon',
                shim:false,
                animCollapse:false,
                resizable : false,
                constrainHeader:true,
                layout: 'fit',
                items:[console_panel]
                ,
                tools:[ 
                {
                    type:'help',
                    tooltip: 'about',
                    handler: function(event, toolEl, panel){
                        Ext.Msg.alert("About","<center><b>Compass Console</b><br><i>Version 0.01</i>")
                    }
                }]
                 
            });
        }
        win.show();
        sendCommand('console_text_area',"Rails.version ");
    }
});
