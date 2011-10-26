Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsDataView",{
    extend:"Ext.view.View",
    alias:'widget.knitkit_imageassetsdataview',
  
    constructor : function(config) {
        config = Ext.apply({
	        autoDestroy:true,
	        style:'overflow:auto',
	        store: Ext.create('Ext.data.Store', {
	            proxy: {
	                type: 'ajax',
	                url: config['url'],
	                reader: {
	                    type: 'json',
	                    root: 'images'
	                }
	            },
	            fields:['name', 'url','shortName']
	        }),
	        tpl: new Ext.XTemplate(
	            '<tpl for=".">',
	            '<div class="thumb-wrap" id="{name}">',
	            '<div class="thumb"><img src="{url}" alt="{name}" class="thumb-img"></div>',
	            '<span>{shortName}</span></div>',
	            '</tpl>')
	    }, config);

        this.callParent([config]);
    }
});