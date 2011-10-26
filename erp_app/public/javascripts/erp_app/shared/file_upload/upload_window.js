Ext.define("Compass.ErpApp.Shared.UploadWindow",{
    extend:"Ext.window.Window",
    alias:'widget.erpappshared_uploadwindow',
    statusIconRenderer : function(value){
        switch(value){
            default:
                return value;
            case 'Pending':
                return '<img src="/images/erp_app/desktop/applications/file_manager/hourglass.png" width=16 height=16>';
            case 'Sending':
                return '<img src="/images/erp_app/desktop/applications/file_manager/loading.gif" width=16 height=16>';
            case 'Error':
                return '<img src="/images/erp_app/desktop/applications/file_manager/cross.png" width=16 height=16>';
            case 'Cancelled':
            case 'Aborted':
                return '<img src="/images/erp_app/desktop/applications/file_manager/cancel.png" width=16 height=16>';
            case 'Uploaded':
                return '<img src="/images/erp_app/desktop/applications/file_manager/tick.png" width=16 height=16>';
        }
    },

    progressBarColumnRenderer : function(value, meta, record, rowIndex, colIndex, store){
        meta.css += ' x-grid3-td-progress-cell';
        var progressClass = "x-grid3-td-progress-cell-pending";
        if(value == 100){
           progressClass = "x-grid3-td-progress-cell-complete";
        }

        var progressBarColumnTemplate = new Ext.XTemplate(
            '<div class="ux-progress-cell-inner ux-progress-cell-inner-center ux-progress-cell-background '+progressClass+'" style="left:{value}%">',
            '<div>{value} %</div>',
            '</div>'
            )
        return progressBarColumnTemplate.apply({
            value: value
        });
    },

    updateFileUploadRecord : function(id, column, value){
        var rec = this.awesomeUploaderGrid.store.getById(id);
        rec.set(column, value);
        rec.commit();
    },

    initComponent: function() {
        Compass.ErpApp.Shared.UploadWindow.superclass.initComponent.call(this, arguments);
        this.addEvents(
            /**
         * @event fileuploaded
         * Fired after file is uploaded.
         * @param {Compass.ErpApp.Shared.UploadWindow } uploadWindow This object
         */
            'fileuploaded'
            );
    },

    constructor : function(config) {
        if(Compass.ErpApp.Utility.isBlank(config)){
            config = {};
        }
        var self = this;
        this.awesomeUploader = new Ext.create("Ext.ux.AwesomeUploader",{
            region:'center',
            standardUploadUrl:config['standardUploadUrl'] || './file_manager/base/upload_file',
            flashUploadUrl:config['flashUploadUrl'] ||'./file_manager/base/upload_file',
            xhrUploadUrl:config['xhrUploadUrl'] ||'./file_manager/base/upload_file',
            extraPostData:config['extraPostData'] || {},
            awesomeUploaderRoot:'/awsome_uploader/',
            height:40,
            allowDragAndDropAnywhere:true,
            autoStartUpload:config['autoStartUpload'] || true,
            maxFileSizeBytes: 15 * 1024 * 1024, // 15 MiB,
            listeners:{
                scope:this,
                fileselected:function(awesomeUploader, file){
                    self.awesomeUploaderGrid.store.insert(1,[{
                        id:file.id,
                        name:file.name,
                        size:file.size,
                        status:'Pending',
                        progress:0
                    }]);
                },
                uploadstart:function(awesomeUploader, file){
                    self.updateFileUploadRecord(file.id, 'status', 'Sending');
                },
                uploadprogress:function(awesomeUploader, fileId, bytesComplete, bytesTotal){
                    self.updateFileUploadRecord(fileId, 'progress', Math.round((bytesComplete / bytesTotal)*100) );
                },
                uploadcomplete:function(awesomeUploader, file, serverData, resultObject){
                    //Ext.Msg.alert('Data returned from server'+ serverData);

                    try{
                        var result = Ext.decode(serverData);//throws a SyntaxError.
                    }catch(e){
                        resultObject.error = 'Invalid JSON data returned';
                        //Invalid json data. Return false here and "uploaderror" event will be called for this file. Show error message there.
                        return false;
                    }
                    resultObject = result;

                    if(result.success){
                        self.updateFileUploadRecord(file.id, 'progress', 100 );
                        self.updateFileUploadRecord(file.id, 'status', 'Uploaded' );
                        this.fireEvent('fileuploaded', this);
                    }else{
                        return false;
                    }
                },
                uploadaborted:function(awesomeUploader, file ){
                    self.updateFileUploadRecord(file.id, 'status', 'Aborted' );
                },
                uploadremoved:function(awesomeUploader, file ){
                    self.awesomeUploaderGrid.store.remove(self.awesomeUploaderGrid.store.getById(file.id));
                },
                uploaderror:function(awesomeUploader, file, serverData, resultObject){
                    resultObject = resultObject || {};

                    var error = 'Error! ';
                    if(resultObject.error){
                        error += resultObject.error;
                    }

                    self.updateFileUploadRecord(file.id, 'progress', 0 );
                    self.updateFileUploadRecord(file.id, 'status', 'Error' );

                }
            }
        });

        this.awesomeUploaderGrid = Ext.create("Ext.grid.GridPanel",{
            width:420,
            region:'south',
            height:200,
            tbar:[
            {
                text:'Start Upload',
                icon:'/images/erp_app/desktop/applications/file_manager/tick.png',
                scope:this,
                handler:function(){
                    self.awesomeUploader.startUpload();
                }
            },
            {
                text:'Abort',
                icon:'/images/erp_app/desktop/applications/file_manager/cancel.png',
                scope:this,
                handler:function(){
                    var selModel = self.awesomeUploaderGrid.getSelectionModel();
                    if(!selModel.hasSelection()){
                        Ext.Msg.alert('','Please select an upload to cancel');
                        return true;
                    }
                    var rec = selModel.selected.first();
                    self.awesomeUploader.abortUpload(rec.data.id);
                }
            },
            {
                text:'Abort All',
                icon:'/images/erp_app/desktop/applications/file_manager/cancel.png',
                scope:this,
                handler:function(){
                    self.awesomeUploader.abortAllUploads();
                }
            },
            {
                text:'Remove',
                icon:'/images/erp_app/desktop/applications/file_manager/cross.png',
                scope:this,
                handler:function(){
                    var selModel = self.awesomeUploaderGrid.getSelectionModel();
                    if(!selModel.hasSelection()){
                        Ext.Msg.alert('','Please select an upload to cancel');
                        return true;
                    }
                    var rec = selModel.selected.first();
                    self.awesomeUploader.removeUpload(rec.data.id);
                }
            },
            {
                text:'Remove All',
                icon:'/images/erp_app/desktop/applications/file_manager/cross.png',
                scope:this,
                handler:function(){
                    self.awesomeUploader.removeAllUploads();
                }
            }],
            store:Ext.create("Ext.data.Store",{
                proxy: {
                    type: 'memory',
                    reader: {
                        type: 'json'
                    }
                },
                fields: ['id','name','size','status','progress']
            }),
            columns:[
            {
                header:'File Name',
                menuDisabled:true,
                sortable:false,
                dataIndex:'name',
                width:150
            },
            {
                header:'Size',
                dataIndex:'size',
                menuDisabled:true,
                sortable:false,
                width:60,
                renderer:Ext.util.Format.fileSize
            },
            {
                header:'&nbsp;',
                dataIndex:'status',
                menuDisabled:true,
                sortable:false,
                width:30,
                renderer:self.statusIconRenderer
            },
            {
                header:'Status',
                dataIndex:'status',
                menuDisabled:true,
                sortable:false,
                width:60
            },
            {
                header:'Progress',
                dataIndex:'progress',
                menuDisabled:true,
                sortable:false,
                width:100,
                renderer:self.progressBarColumnRenderer
            }
            ]

        });

        config = Ext.apply({
            title:'File Upload',
            layout:'border',
            autoWidth:true,
            height:275,
            width:455,
            iconCls:'icon-upload',
            items:[this.awesomeUploader,this.awesomeUploaderGrid]
        }, config);

        Compass.ErpApp.Shared.UploadWindow.superclass.constructor.call(this, config);
    }

});