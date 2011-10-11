Compass.ErpApp.Widgets.Gallery = {
    addGallery:function(){
		
		var imageNames = [];
		var imagesSelected = [];
		
		// Set up a model to use in our Store
		// Ext.define('Images', {
		//     extend: 'Ext.data.Model',
		//     fields: [
		// 		{name: 'url', type: 'string'},
		// 		{name: 'name', type: 'string'}
		// 	]
		// });
		// 
		// var selectedImagesStore = Ext.create('Ext.data.Store', {
		// 	model: 'Images'
		// });
	
		var selectedImagesStore = Ext.create('Ext.data.Store', {
		    storeId:'selectedImagesStore',
			fields:[{name: 'url'}, {name: 'name'}],
			data: imagesSelected
		});
		
		var uploadWindow = new Compass.ErpApp.Shared.UploadWindow({
		   	standardUploadUrl:'./knitkit/image_assets/upload_file_paperclip',
		   	flashUploadUrl:'./knitkit/image_assets/upload_file_paperclip',
		   	xhrUploadUrl:'./knitkit/image_assets/upload_file_paperclip',
		    extraPostData:{
		    	directory:"public/images/high_slide"
		    },
		   	listeners:{fileuploaded:function(uploadWindow, result, file){
				if(result.success){
					imageNames.push({name:file.name});
				}
			}}
		 });
		
		var imageAssetsDataView = Ext.create("Ext.view.View",{
			itemSelector: 'div.thumb-wrap',
	        id:'images-gallery',
	        autoDestroy:true,
	        style:'overflow:auto',
	        store: Ext.create('Ext.data.Store', {
	            proxy: {
	                type: 'ajax',
	                url: './knitkit/image_assets/get_images',
	                reader: {
	                    type: 'json',
	                    root: 'images'
	                }
	            },
	            fields:['name', 'url', 'shortName']
	        }),
	        tpl: new Ext.XTemplate(
	            '<tpl for=".">',
	            '<div class="thumb-wrap" id="{name}">',
	            '<div class="thumb"><img src="{url}" class="thumb-img"></div>',
	            '<span>{shortName}</span></div>',
	            '</tpl>'
	            ),
		    listeners:{
                'itemcontextmenu':function(view, record, htmlitem, index, e, options){
                    e.stopEvent();
                    var contextMenu = Ext.create("Ext.menu.Menu",{
                        items:[
                        {
                            text:'Add to Gallery',
                            iconCls:'icon-picture',
                            handler:function(btn){
								imagesSelected.push({url:record.get('url'), name:record.get('name')});
								var store = selectedImagesStore;
								store.add({url:record.get('url'), name:record.get('name')});
								store.load();
                            }
                        }
                        ]
                    });
                    contextMenu.showAt(e.xy);
                }
            }
	    });
		
		var imagesPanel = new Ext.Panel({
	        id:'image-assets-gallery',
	        autoDestroy:true,
	        title:'Available Images',
	        region:'south',
			height: 150,
	        layout:'fit',
	        items: imageAssetsDataView
	    });
		
		var fileTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
	        //TODO_EXTJS4 this is added to fix error should be removed when extjs 4 releases fix.
	        viewConfig:{
	            loadMask: false
	        },
	        autoDestroy:true,
	        allowDownload:false,
	        addViewContentsToContextMenu:false,
	        rootVisible:true,
	        controllerPath:'./knitkit/image_assets',
	        standardUploadUrl:'./knitkit/image_assets/upload_file',
	        xhrUploadUrl:'./knitkit/image_assets/upload_file',
	        url:'./knitkit/image_assets/expand_directory',
	        containerScroll: true,
			// height:100,
			width: 240,
	        title:'Images',
	        collapsible:true,
	        region:'west',
			// frame:false,
	        listeners:{
	            'itemclick':function(view, record, item, index, e){
	                e.stopEvent();
	                if(!record.data["leaf"])
	                {
	                    var store = imageAssetsDataView.getStore();
	                    store.setProxy({
	                        type: 'ajax',
	                        url: './knitkit/image_assets/get_images',
	                        reader: {
	                            type: 'json',
	                            root: 'images'
	                        },
	                        extraParams:{
	                            directory:record.data.id
	                        }
	                    });
	                    store.load();
	                }
	                else{
	                    return false;
	                }
	            },
	            'fileDeleted':function(fileTreePanel, node){
	                var store = self.imageAssetsDataView.getStore();
	                store.load();
	            },
	            'fileUploaded':function(fileTreePanel, node){
	                var store = self.imageAssetsDataView.getStore();
	                store.load();
	            }
	        }
	    });
		
		function renderIcon(val) {
		        return '<img src="' + val + '" class="miniThumb">';
		}
		
		var selectedImages = Ext.create('Ext.grid.Panel', {
			title:'Selected Images',
			store: selectedImagesStore,
			columns: [
				{ text: 'Thumb', dataIndex: 'url', renderer: renderIcon, width: 60, },
				{ text: 'Name', dataIndex: 'name', width: 140 },
				{
					xtype: 'actioncolumn',
					width: 30,
					items: [{
						icon: '/images/delete.gif',
						tooltip: 'Remove Image',
						handler: function(grid, rowIndex, colIndex) {
							imagesSelected.splice(rowIndex, 1);
							var store = selectedImagesStore;
							store.load();
						}
					}]
				}
			],
			region:'center',
			// containerScroll: true,
			// height:100,
			// width: 235,
			// containerScroll: true,
			// collapsible:true,
			// frame:true
			// renderTo: Ext.getBody()
		});

		var tabs = [
			{
				xtype   : 'panel',
				layout	: 'border',
	            title   :'Gallery',
				height	: 410,
				width	: 450,
				tbar	: [
					{
		   				text   : 'Add images',
						style  : 'margin: 2px 0 2px 10px;',
           				handler: function(){uploadWindow.show();}
					}
				],
	            items   : [
	                
					fileTreePanel, 
					selectedImages,
					// {
					// 	title:'Selected Images',
					// 				        region:'center',
					// 	containerScroll: true,
					// 				        // height:100,
					// 	width: 240,
					// 	containerScroll: true,
					// 	collapsible:true,
					// 	// frame:true
					// },
					imagesPanel
				]
	        },
	        {
	            xtype     : 'container',
	            title     :'Style',
	            style     : 'padding:5px 5px 0',
	            items   : [
	                {
	                    xtype: 'fieldset',
					  	title: 'Controls',
					  	id: 'fsControls',
					  	height: 'auto',
					  	layout: 'column',
					  	defaults: {
					  		border: false,
					  		bodyStyle: 'padding: 0'
					  	},
					  	items: [
		            		{
		            		    xtype: 'combo',
								columnWidth: .99,
		            		    forceSelection:true,
		            		    store: [
		            		    ['none', 'None (disable controller)'],
								['default', 'Large white buttons'],
								['controls-in-heading', 'Small white buttons'],
								['large-dark', 'Large dark buttons'],
								['text-controls', 'White buttons with text'],
		            		    ],
		            		    fieldLabel:'Style',
		            		    value:'default',
		            		    name: 'controlsPreset',
		            		    allowBlank: false,
		            		    triggerAction: 'all'
		            		}
						]
					}
	            ]
	        },
	        {
	            title  : 'Behavior',
	            xtype  : 'container',
				style  : 'padding:5px 5px 0',
				items   : [
					{
					 	xtype: 'fieldset',
					  	title: 'Thumbstrip',
					  	id: 'fsThumbstrip',
					  	height: 'auto',
					  	layout: 'column',
					  	defaults: {
					  		border: false,
					  		bodyStyle: 'padding: 0'
					  	},
					  	items: [
							{
								xtype: 'checkbox',
								fieldLabel: 'Thumbstrip',
								boxLabel: 'Enable',
								columnWidth: .99,
								store: [['true','true'],['false','false'],],
								value: 'true',
								inputValue: 'true',
								checked: true,
								name: 'thumbstripEnabled'
							},
	                		{
		            		    xtype: 'combo',
								columnWidth: .99,
		            		    forceSelection:true,
		            		    store: [
		            		    ['horizontal','horizontal'],
		            		    ['vertical','vertical'],
		            		    ['float','float'],
		            		    ],
		            		    fieldLabel:'Mode',
		            		    value:'horizontal',
		            		    name: 'thumbstripMode',
		            		    allowBlank: false,
		            		    triggerAction: 'all'
		            		},
		            		{
		            		    xtype: 'combo',
								columnWidth: .99,
		            		    forceSelection:true,
		            		    store: [
		            		    ['above','above'],
		            		    ['leftpanel','leftpanel'],
		            		    ['rightpanel','rightpanel'],
								['below', 'below'],
		            		    ],
		            		    fieldLabel:'Position',
		            		    value:'below',
		            		    name: 'thumbstripPosition',
		            		    allowBlank: false,
		            		    triggerAction: 'all'
		            		}
						]
					},
					{
	                    xtype: 'fieldset',
					  	title: 'Animation',
					  	id: 'fsAnimation',
					  	height: 'auto',
					  	layout: 'column',
					  	defaults: {
					  		border: false,
					  		bodyStyle: 'padding: 0'
					  	},
					  	items: [
		            		{
		            		    xtype: 'combo',
								columnWidth: .99,
		            		    forceSelection:true,
		            		    store: [
		            		    ['easeInQuad','easeInQuad'],
								['linearTween','linearTween'],
								['easeInCirc','easeInCirc'],
								['easeInBack','easeInBack'],
								['easeOutBack','easeOutBack'],
		            		    ],
		            		    fieldLabel:'Easing',
		            		    value:'easeInQuad',
		            		    name: 'animationEasing',
		            		    allowBlank: false,
		            		    triggerAction: 'all'
		            		},
							{
								xtype: 'checkbox',
								fieldLabel: 'Fade in and out',
								columnWidth: .99,
								store: [['true','true'],['false','false'],],
								value: 'false',
								inputValue: 'true',
								name: 'animationFadeInOut'
							},
							{
								xtype: 'combo',
								columnWidth: .99,
								store: [
								['easeInBack','easeInBack'],
								['easeOutBack','easeOutBack'],
								],
								fieldLabel: 'Easing Close',
								name: 'animationEasingClose'
							},
							{
								xtype: 'numberfield',
								columnWidth: .99,
								fieldLabel: 'Open duration (ms)',
								name: 'expandDuration',
								value: 500,
								increment: 25,
								maxValue: 5000,
								minValue: 0,
								allowDecimals: false
							}, {
								xtype: 'numberfield',
								columnWidth: .99,
								fieldLabel: 'Close duration (ms)',
								name: 'restoreDuration',
								value: 500,
								maxValue: 5000,
								minValue: 0,
								increment: 25,
								allowDecimals: false
							},
						]
					}
	            ]
	        }
	    ];

	    var tabPanel = {
	        xtype             :'tabpanel',
	        activeTab         : 0,
	        deferredRender    : false,
	        layoutOnTabChange : true,
	        border            : false,
	        flex              : 1,
	        plain             : true,
	        items             : tabs
	    };
        
        var formPanel = Ext.create("Ext.form.Panel",{
            region:'center',
            frame:false,
            bodyStyle:'padding:5px 0',
            items: [tabPanel]
        });


        var addGalleryWidgetWindow = Ext.create("Ext.window.Window",{
            layout:'border',
            width:500,
            title:'Add Gallery Widget',
            height:500,
            plain: true,
            buttonAlign:'center',
            items:[formPanel],
			buttons: [{
                text:'Submit',
                listeners:{
                    'click':function(button){
						var basicForm = formPanel.getForm();
						var thumbstripEnabled = basicForm.findField('thumbstripEnabled').getValue();
						var thumbstripMode = basicForm.findField('thumbstripMode').getValue();
						var thumbstripPosition = basicForm.findField('thumbstripPosition').getValue();
						var controlsPreset = basicForm.findField('controlsPreset').getValue();
						var animationEasing = basicForm.findField('animationEasing').getValue();
						var animationFadeInOut = basicForm.findField('animationFadeInOut').getValue();
						var animationEasingClose = basicForm.findField('animationEasingClose').getValue();
						var expandDuration = basicForm.findField('expandDuration').getValue();
						var restoreDuration = basicForm.findField('restoreDuration').getValue();
						var selectedImagesStore = Ext.data.StoreManager.lookup('selectedImagesStore');
						var data = {thumbstripMode:thumbstripMode,thumbstripPosition:thumbstripPosition,controlsPreset:controlsPreset,animationEasing:animationEasing,animationFadeInOut:animationFadeInOut,animationEasingClose:animationEasingClose,expandDuration:expandDuration,restoreDuration:restoreDuration,imageNames:imageNames,imagesSelected:imagesSelected,thumbstripEnabled:thumbstripEnabled}
                        var tpl = new Ext.XTemplate(
							'<tpl if="thumbstripEnabled">',
							'	show thumbstip\n',
							'</tpl>',
							'<div class="highslide-gallery">\n',
							'<tpl for="imagesSelected">',
							'    <a class="highslide" onclick="return hs.expand(this)" href="{url}">\n',
							'        <img class="resizedImage" title="Click to enlarge" src="{url}" alt="Full-image">\n',
							'    </a>\n',
							'</tpl>',
							'<tpl for="imageNames">',
							'    <a class="highslide" onclick="return hs.expand(this)" href="/images/high_slide/{name}/original/{name}">\n',
							'        <img title="Click to enlarge" src="/images/high_slide/{name}/thumb/{name}" alt="Full-image">\n',
							'    </a>\n',
							'</tpl>',
							'</div>\n',
							'<script type="text/javascript">\n',
							'	hs.graphicsDir = "../images/high_slide/graphics/";\n',
							'	hs.showCredits = false;\n',
							'	hs.align = "center";\n',
							"	hs.transitions = ['expand', 'crossfade'];\n",
							'	hs.outlineType = "rounded-white";\n',
							'	hs.easing = "{animationEasing}";\n',
							'	hs.fadeInOut = {animationFadeInOut};\n',
							'	hs.easingClose = "{animationEasingClose}";\n',
							'	hs.expandDuration = {expandDuration};\n',
							'	hs.restoreDuration = {restoreDuration};\n',
							'// Add the slideshow controller\n',
							'	hs.addSlideshow({\n',
							'		interval: 5000,\n',
							'		repeat: false,\n',
							'		useControls: true,\n',
							'		fixedControls: "fit",\n',
							'		overlayOptions: {\n',
							'			className: "{controlsPreset}",\n',
							'			opacity: 0.75,\n',
							'			position: "bottom center",\n',
							'			offsetX: 0,\n',
							'			offsetY: -10,\n',
							'			hideOnMouseOut: true\n',
							'		},\n',
							'<tpl if="thumbstripEnabled == true">',
							'		thumbstrip: {\n',
							'			mode: "{thumbstripMode}",\n',
							'			position: "{thumbstripPosition}",\n',
							'			relativeTo: "image"\n',
							'		}\n',
							'</tpl>',
							'	});\n',
							'</scr'+'ipt>');
                        var content = tpl.apply(data);
                        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(content);
                        addGalleryWidgetWindow.close();
                    }
                }
            },{
                text: 'Close',
                handler: function(){
                    addGalleryWidgetWindow.close();
                }
            }]
        });
        addGalleryWidgetWindow.show();
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Gallery',
    iconUrl:'/images/icons/gallery/gallery-icon_48x48.png',
	onClick:Compass.ErpApp.Widgets.Gallery.addGallery
});