Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.InquiriesGridPanel",{
    extend:"Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel",
    alias:'widget.knitkit_inquiriesgridpanel',
    deleteInquiry : function(rec){
        var self = this;
        Ext.getCmp('knitkitCenterRegion').setWindowStatus('Deleting inquiry...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/inquiries/delete',
            method: 'POST',
            params:{
                id:rec.get("id")
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    Ext.getCmp('knitkitCenterRegion').clearWindowStatus();
                    Ext.getCmp('DynamicEditableGrid').getStore().reload();
                }
                else{
                    Ext.Msg.alert('Error', 'Error deleting inquiry');
                    Ext.getCmp('knitkitCenterRegion').clearWindowStatus();
                }
            },
            failure: function(response) {
                Ext.getCmp('knitkitCenterRegion').clearWindowStatus();
                Ext.Msg.alert('Error', 'Error deleting inquiry');
            }
        });
    },
    constructor : function(config) {
        config = Ext.apply({
            id:'InquiriesGridPanel',
            title:'Website Inquiries',
            dataUrl: './knitkit/inquiries/get/' + config['websiteId'],
            setupUrl: './knitkit/inquiries/setup',
            editable:false,
            page:true,
            pageSize:20,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty'
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.InquiriesGridPanel.superclass.constructor.call(this, config);
    }
});
