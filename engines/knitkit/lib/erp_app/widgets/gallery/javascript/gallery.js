Compass.ErpApp.Widgets.Gallery = {
    addGallery:function(){
		 var uploadWindow = new Compass.ErpApp.Shared.UploadWindow({
				standardUploadUrl:'./knitkit/image_assets/upload_file',
				flashUploadUrl:'./knitkit/image_assets/upload_file',
				xhrUploadUrl:'./knitkit/image_assets/upload_file',
                extraPostData:{
                        directory:'public/images/high_slide'
                    },
            });
		  Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror('<%= render_widget :gallery  %>');
          uploadWindow.show();
	}
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Gallery',
    iconUrl:'/images/icons/gallery/gallery-icon_48x48.png',
	onClick:Compass.ErpApp.Widgets.Gallery.addGallery
    // onClick:"alert('My new widget A widget to create High Slide Galleries');"
});