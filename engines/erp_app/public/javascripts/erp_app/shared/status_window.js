Compass.ErpApp.Shared.StatusWindow = Ext.extend(Ext.Window, {
    setStatus : function(newStatus){
        this.statusLabel.update(newStatus);
    },

    clearStatus : function(){
        this.statusLabel.update('');
    },

    afterRender : function(){
        this.statusLabel = Ext.get(document.createElement('span'));
        var divElement = Ext.get(document.createElement('div').appendChild(this.statusLabel.dom));
        divElement.applyStyles('float:right;padding-right:5px;');
        this.header.appendChild(divElement);
        
        Compass.ErpApp.Shared.StatusWindow.superclass.afterRender.call(this);
    }
});

Ext.reg('statuswindow', Compass.ErpApp.Shared.StatusWindow);
