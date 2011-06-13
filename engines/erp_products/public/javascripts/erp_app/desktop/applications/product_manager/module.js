Ext.ns("Compass.ErpApp.Desktop.Applications");

//
//module
//

Compass.ErpApp.Desktop.Applications.ProductManager = Ext.extend(Ext.app.Module, {
    id:'product_manager-win',
    init : function(){
        this.launcher = {
            text: 'Products',
            iconCls:'icon-product',
            handler : this.createWindow,
            scope: this
        }
    },
    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('product_manager');
        if(!win){
            win = desktop.createWindow({
                id: 'product_manager',
                title:'Products',
                width:1000,
                height:550,
                iconCls: 'icon-product',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'fit',
                items:[{
                    xtype:'productmanagement_productspanel'
                }]
            });
        }
        win.show();
    }
});

//
//form to manage description and title
//

Compass.ErpApp.Desktop.Applications.ProductManager.ProductDescriptionForm = Ext.extend(Ext.FormPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.ProductManager.ProductDescriptionForm.superclass.initComponent.call(this, arguments);

        this.addEvents(
            /**
         * @event saved
         * Fired after form is saved.
         * @param {Compass.ErpApp.Desktop.Applications.ProductManager.ProductDescriptionForm} form this object
         * @param {integer} Newly create id
         */
            'saved'
            );
    },

    constructor : function(config) {
        var self = this;
        config = Ext.apply({
            labelWidth:40,
            frame:true,
            autoHeight: true,
            buttonAlign:'center',
            bodyStyle:'padding:5px 5px 0',
            items: [
            {
                fieldLabel:'Title',
                xtype:'textfield',
                allowBlank:false,
                width:500,
                name:'title'

            },
            {
                xtype : 'label',
                html : 'Describe your product:',
                cls : "x-form-item x-form-item-label card-label"
            },
            {
                xtype: 'ckeditor',
                allowBlank:false,
                ckEditorConfig:{
                    height:'345px',
                    extraPlugins:'jwplayer',
                    toolbar:[
                    ['Source','-','Preview','Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
                    ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
                    ['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
                    ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote','CreateDiv'],
                    ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
                    ['BidiLtr', 'BidiRtl' ],
                    ['Link','Unlink','Anchor'],
                    ['jwplayer','Flash','HorizontalRule'],
                    ['Styles','Format','Font','FontSize'],
                    ['TextColor','BGColor'],
                    ['Maximize', 'ShowBlocks','-','About']
                    ]
                }
            },
            {
                xtype:'hidden',
                name:'description'
            }
            ],
            buttons:[
            {
                text:'Save',
                handler:function(btn){
                    var formPanel = btn.findParentByType('form');
                    var basicForm = formPanel.getForm();

                    //ckeditor does not post.  Get the value and set to hidden field
                    var ckeditor = formPanel.findByType('ckeditor')[0];
                    basicForm.findField('description').setValue(ckeditor.getValue());

                    basicForm.submit({
                        success:function(form, action){
                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                            if(obj.success){
                                self.fireEvent('saved', this, obj.id);
                            }
                            else{
                                Ext.Msg.alert("Error", 'Error creating product');
                            }
                        },
                        failure:function(form, action){
                            Ext.Msg.alert("Error", 'Error creating product');
                        }
                    });
                }
            }
            ]
        }, config);

        Compass.ErpApp.Desktop.Applications.ProductManager.ProductDescriptionForm.superclass.constructor.call(this, config);
    }
});

Ext.reg('productmanager_productdescriptionform', Compass.ErpApp.Desktop.Applications.ProductManager.ProductDescriptionForm);

//
//form to manage pricing
//

Compass.ErpApp.Desktop.Applications.ProductManager.ProductPricingPanel = Ext.extend(Ext.Panel, {
    updatePrice : function(rec){
        var formPanel = this.findByType('form')[0];
        formPanel.buttons[0].setText('Update Price');
        formPanel.buttons[1].show();
        formPanel.getForm().setValues(rec.data);
    },

    deletePrice : function(rec){
        var self = this;
        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this price?', function(btn){
            if(btn == 'no'){
                return false;
            }
            else
            {
                var conn = new Ext.data.Connection();
                conn.request({
                    url: './product_manager/delete_price/'+rec.get('pricing_plan_id'),
                    success: function(response) {
                        var obj =  Ext.util.JSON.decode(response.responseText);
                        if(obj.success){
                            Ext.getCmp('productListPanel').loadProducts();
                            self.findByType('grid')[0].getStore().reload();
                        }
                        else{
                            Ext.Msg.alert('Error', 'Error deleting price.');
                        }
                    },
                    failure: function(response) {
                        Ext.Msg.alert('Error', 'Error deleting price.');
                    }
                });
            }
        });
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.ProductManager.ProductPricingPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var self = this;

        var expander = new Ext.ux.grid.RowExpander({
            tpl : new Ext.Template('<p><b>Comments:</b> {comments}</p><br>')
        });

        this.pricesGridPanel = {
            layout:'fit',
            xtype:'grid',
            region:'center',
            plugins: expander,
            split:true,
            width:'100%',
            columns: [
            expander,
            {
                header:'Description',
                width:370,
                sortable: false,
                dataIndex: 'description'
            },
            {
                header: 'Price',
                width: 75,
                sortable: true,
                dataIndex: 'price',
                renderer:function(v){
                    return v.toFixed(2);
                }
            },
            {
                header: 'Currency',
                width: 75,
                sortable: true,
                dataIndex: 'currency_display'
            },
            {
                header: 'From Date',
                width: 90,
                sortable: true,
                dataIndex: 'from_date',
                renderer: Ext.util.Format.dateRenderer('m/d/Y')
            },
            {
                header: 'Thru Date',
                width: 90,
                sortable: true,
                dataIndex: 'thru_date',
                renderer: Ext.util.Format.dateRenderer('m/d/Y')
            },
            {
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'Update',
                align:'center',
                width:60,
                items:[{
                    icon:'/images/icons/edit/edit_16x16.png',
                    tooltip:'Update',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        self.updatePrice(rec);
                    }
                }]
            },
            {
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'Delete',
                align:'center',
                width:60,
                items:[{
                    icon:'/images/icons/delete/delete_16x16.png',
                    tooltip:'Delete',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        self.deletePrice(rec);
                    }
                }]
            }
            ],
            loadMask: true,
            stripeRows: true,
            store:{
                xtype:'jsonstore',
                url: './product_manager/prices/'+config.productTypeId,
                autoLoad: true,
                root: 'prices',
                id:'id',
                fields:[{
                    name:'price',
                    type:'decimal'
                }, 'currency', 'currency_display', 'from_date', 'thru_date', 'description','comments','pricing_plan_id']
            }
        }

        this.addPriceFormPanel = {
            xtype:'form',
            labelWidth:60,
            collapsible:true,
            frame:true,
            region:'south',
            split:true,
            autoHeight: true,
            buttonAlign:'center',
            bodyStyle:'padding:5px 5px 0',
            url:'./product_manager/new_and_update_price',
            items: [
            {
                xtype:'textfield',
                width:400,
                name:'description',
                fieldLabel:'Description'
            },
            {
                layout:'column',
                defaults:{
                    columnWidth:0.25,
                    layout:'form',
                    border:false,
                    xtype:'panel',
                    bodyStyle:'padding:0 18px 0 0'
                },
                border:false,
                items:[{
                    items:[
                    {
                        fieldLabel:'Price',
                        xtype:'numberfield',
                        width:75,
                        allowBlank:false,
                        name:'price'
                    }
                    ]
                },
                {
                    items:[
                    {
                        fieldLabel:'Currency',
                        xtype:'combo',
                        width:75,
                        id : 'call_center_party_country',
                        allowBlank : false,
                        store : {
                            autoLoad: true,
                            xtype:'jsonstore',
                            root: 'currencies',
                            url:'./product_manager/currencies',
                            fields: [
                            {
                                name:'internal_identifier'
                            },
                            {
                                name:'id'
                            }
                            ]
                        },
                        hiddenName: 'currency',
                        hiddenField: 'currency',
                        valueField: 'id',
                        displayField: 'internal_identifier',
                        mode:'local',
                        forceSelection : true,
                        triggerAction : 'all',
                        name:'currency'
                    }
                    ]
                },
                {
                    items:[
                    {
                        fieldLabel:'From Date',
                        xtype:'datefield',
                        allowBlank:false,
                        name:'from_date'
                    }
                    ]
                },
                {
                    items:[
                    {
                        fieldLabel:'Thru Date',
                        xtype:'datefield',
                        allowBlank:false,
                        name:'thru_date'
                    }
                    ]
                }]
            },
            {
                xtype:'textarea',
                height:50,
                width:400,
                name:'comments',
                fieldLabel:'Comments'
            },
            {
                xtype:'hidden',
                name:'product_type_id',
                value:config.productTypeId
            },
            {
                xtype:'hidden',
                name:'pricing_plan_id'
            }
            ],
            buttons:[
            {
                text:'Add Price',
                handler:function(btn){
                    var formPanel = btn.findParentByType('form');
                    var basicForm = formPanel.getForm();

                    basicForm.submit({
                        reset:true,
                        success:function(form, action){
                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                            if(obj.success){
                                self.findByType('form')[0].buttons[0].setText('Add Price');
                                self.findByType('form')[0].buttons[1].hide();
                                Ext.getCmp('productListPanel').loadProducts();
                                self.findByType('grid')[0].getStore().reload();
                            }
                            else{
                                Ext.Msg.alert("Error", 'Error creating price');
                            }
                        },
                        failure:function(form, action){
                            Ext.Msg.alert("Error", 'Error creating price');
                        }
                    });
                }
            },
            {
                text:'Cancel',
                hidden:true,
                handler:function(btn){
                    var formPanel = btn.findParentByType('form');
                    var basicForm = formPanel.getForm();
                    basicForm.reset();
                    self.findByType('form')[0].buttons[0].setText('Add Price');
                    self.findByType('form')[0].buttons[1].hide();
                }
            }
            ]
        }

        config = Ext.apply({
            title:'Pricing',
            layout:'border',
            width:'100%',
            height:485,
            items:[this.pricesGridPanel, this.addPriceFormPanel]
        }, config);

        Compass.ErpApp.Desktop.Applications.ProductManager.ProductPricingPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('productmanager_productpricingpanel', Compass.ErpApp.Desktop.Applications.ProductManager.ProductPricingPanel);

//
//Panel for product images
//

Compass.ErpApp.Desktop.Applications.ProductManager.ProductImagesPanel = Ext.extend(Ext.Panel, {
    deleteImage : function(id){
        var self = this;
        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this image?', function(btn){
            if(btn == 'no'){
                return false;
            }
            else
            {
                var conn = new Ext.data.Connection();
                conn.request({
                    url: './product_manager/delete_image/'+id,
                    success: function(response) {
                        var obj =  Ext.util.JSON.decode(response.responseText);
                        if(obj.success){
                            self.imageAssetsDataView.getStore().reload();
                        }
                        else{
                            Ext.Msg.alert('Error', 'Error deleting image.');
                        }
                    },
                    failure: function(response) {
                        Ext.Msg.alert('Error', 'Error deleting image.');
                    }
                });
            }
        });
    },

    constructor : function(config) {
        var self = this;
        var productTypeId = config.productTypeId;
        var uploadUrl = './product_manager/new_image'
        
        this.imageAssetsDataView = new Ext.DataView({
            autoDestroy:true,
            itemSelector: 'div.thumb-wrap',
            style:'overflow:auto',
            multiSelect: true,
            plugins: new Ext.DataView.DragSelector({
                dragSafe:true
            }),
            store: new Ext.data.JsonStore({
                url: './product_manager/images/'+productTypeId,
                autoLoad: true,
                root: 'images',
                id:'id',
                fields:['name', 'url', 'shortName', 'id']
            }),
            tpl: new Ext.XTemplate(
                '<tpl for=".">',
                '<div class="thumb-wrap" id="{name}">',
                '<div class="thumb"><img src="{url}" class="thumb-img"></div>',
                '<span>{shortName}</span></div>',
                '</tpl>'
                ),
            listeners:{
                'contextmenu':function(dataView, index, node, e){
                    e.stopEvent();
                    var contextMenu = new Ext.menu.Menu({
                        items:[
                        {
                            text:'Delete',
                            iconCls:'icon-delete',
                            handler:function(btn){
                                self.deleteImage(self.imageAssetsDataView.getStore().getAt(index).get('id'));
                            }
                        }
                        ]
                    });
                    contextMenu.showAt(e.xy);
                }
            }
        });

        config = Ext.apply({
            id:'product-image-assets',
            title:'Images',
            autoDestroy:true,
            margins: '5 5 5 0',
            autoHeight:true,
            layout:'fit',
            items:[this.imageAssetsDataView],
            tbar:{
                items:[
                {
                    text:'Add Image',
                    iconCls:'icon-upload',
                    handler:function(btn){
                        var uploadWindow = new Compass.ErpApp.Shared.UploadWindow({
                            standardUploadUrl:uploadUrl,
                            flashUploadUrl:uploadUrl,
                            xhrUploadUrl:uploadUrl,
                            extraPostData:{
                                product_type_id:productTypeId
                            },
                            listeners:{
                                'fileuploaded':function(){
                                    var dataView = btn.findParentByType('panel').findByType('dataview')[0];
                                    dataView.getStore().reload();
                                    Ext.getCmp('productListPanel').loadProducts();
                                }
                            }
                        });
                        uploadWindow.show();
                    }
                }
                ]
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.ProductManager.ProductImagesPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('productmanager_productimagespanel', Compass.ErpApp.Desktop.Applications.ProductManager.ProductImagesPanel);


//
//Inventory Management
//

Compass.ErpApp.Desktop.Applications.ProductManager.InventoryFormPanel = Ext.extend(Ext.FormPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.ProductManager.InventoryFormPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        config = Ext.apply({
            title:'Inventory',
            labelWidth:75,
            frame:true,
            autoHeight: true,
            buttonAlign:'left',
            bodyStyle:'padding:5px 5px 0',
            url:'./product_manager/update_inventory',
            items:[
            {
                fieldLabel:'SKU #',
                xtype:'textfield',
                width:200,
                allowBlank:true,
                name:'sku'
            },{
                fieldLabel:'# Available',
                xtype:'numberfield',
                width:75,
                allowBlank:false,
                name:'number_available'
            },
            {
                xtype:'hidden',
                name:'product_type_id',
                value:config.productTypeId
            },
            ],
            buttons:[
            {
                text:'Update',
                handler:function(btn){
                    var formPanel = btn.findParentByType('form');
                    var basicForm = formPanel.getForm();

                    basicForm.submit({
                        reset:false,
                        success:function(form, action){
                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                            if(obj.success){
                                Ext.getCmp('productListPanel').loadProducts();
                            }
                            else{
                                Ext.Msg.alert("Error", 'Error creating price');
                            }
                        },
                        failure:function(form, action){
                            Ext.Msg.alert("Error", 'Error creating price');
                        }
                    });
                }
            }
            ]
        }, config);

        Compass.ErpApp.Desktop.Applications.ProductManager.InventoryFormPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('productmanager_inventoryformpanel', Compass.ErpApp.Desktop.Applications.ProductManager.InventoryFormPanel);

//
//Add product window
//

Compass.ErpApp.Desktop.Applications.ProductManager.AddProductWindow = Ext.extend(Ext.Window, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.ProductManager.AddProductWindow.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var self = this;
        config = Ext.apply({
            title:'Add New Product',
            width:800,
            height:525,
            autoScroll:true,
            buttonAlign:'center',
            items:{
                xtype:'productmanager_productdescriptionform',
                url:'./product_manager/new',
                listeners:{
                    saved:function(form, newId){
                        Ext.getCmp('productListPanel').loadProducts();
                        var win = new Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow({
                            productTypeId:newId
                        });
                        win.show();
                        self.close();
                    }
                }
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.ProductManager.AddProductWindow.superclass.constructor.call(this, config);
    }
});

Ext.reg('productmanager_addproductwindow', Compass.ErpApp.Desktop.Applications.ProductManager.AddProductWindow);

//
//Update product window
//

Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow = Ext.extend(Ext.Window, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var self = this;
        var activeTab = config['activeTab'] | 0

        var tabLayout = {
            xtype:'tabpanel',
            items:[
            {
                title:'Description',
                xtype:'productmanager_productdescriptionform',
                url:'./product_manager/update/'+config.productTypeId,
                productTypeId:config.productTypeId,
                listeners:{
                    'saved':function(form){
                        Ext.getCmp('productListPanel').loadProducts();
                    },
                    'activate':function(panel){
                        if(!Compass.ErpApp.Utility.isBlank(panel.initialConfig['productTypeId'])){
                            var self = this;
                            var conn = new Ext.data.Connection();
                            conn.request({
                                url: './product_manager/show/'+panel.initialConfig['productTypeId'],
                                success: function(response) {
                                    var obj =  Ext.util.JSON.decode(response.responseText);
                                    self.getForm().setValues(obj);
                                    self.findByType('ckeditor')[0].setValue(obj.description);
                                },
                                failure: function(response) {
                                    Ext.Msg.alert('Error', 'Error loading product details.');
                                }
                            });
                        }
                    }

                }
            },
            {
                xtype:'productmanager_productimagespanel',
                productTypeId:config.productTypeId
            },
            {
                xtype:'productmanager_productpricingpanel',
                productTypeId:config.productTypeId
            },
            {
                xtype:'productmanager_inventoryformpanel',
                productTypeId:config.productTypeId,
                listeners:{
                    'activate':function(panel){
                        var self = this;
                        var conn = new Ext.data.Connection();
                        conn.request({
                            url: './product_manager/inventory/'+panel.initialConfig['productTypeId'],
                            success: function(response) {
                                var obj =  Ext.util.JSON.decode(response.responseText);
                                self.getForm().setValues(obj);
                            },
                            failure: function(response) {
                                Ext.Msg.alert('Error', 'Error loading inventory.');
                            }
                        });
                    }
                }
            }
            ]
        }

        config = Ext.apply({
            title:'Update Product',
            width:860,
            height:560,
            autoScroll:true,
            items:[tabLayout],
            listeners:{
                show:function(comp){
                    comp.findByType('tabpanel')[0].setActiveTab(activeTab);
                }
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow.superclass.constructor.call(this, config);
    }
});

Ext.reg('productmanager_updateproductwindow', Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow);
