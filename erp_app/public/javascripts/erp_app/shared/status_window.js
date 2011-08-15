Ext.define("Compass.ErpApp.Shared.StatusWindow",{
    extend:"Ext.window.Window",
    alias:"widget.statuswindow",
    setStatus : function(newStatus){
        this.wait = Ext.MessageBox.show({
           msg: newStatus || 'Processing your request, please wait...',
           progressText: 'Working...',
           width:300,
           wait:true,
           waitConfig: {interval:200},
           iconCls:'icon-gear'
       });
    },

    clearStatus : function(){
        this.wait.hide();
    }
});
