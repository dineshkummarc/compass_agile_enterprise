Compass.ErpApp.Desktop.Applications.Scaffold.WebsiteInquiryActiveExtGrid = Ext.extend(Compass.ErpApp.Shared.ActiveExt.ActiveExtGridPanel, {
    constructor : function(config){
        config = Ext.apply({
            title:'WebsiteInquiry',
            modelUrl:'./scaffold/website_inquiry/',
            editable:true,
            page:true,
            pageSize:30,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty'
        }, config);
        Compass.ErpApp.Desktop.Applications.Scaffold.WebsiteInquiryActiveExtGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('website_inquiry_activeextgrid', Compass.ErpApp.Desktop.Applications.Scaffold.WebsiteInquiryActiveExtGrid);