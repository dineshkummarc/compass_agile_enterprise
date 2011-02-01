Compass.ErpApp.Shared.UploadWindow  = Ext.extend(Ext.Window, {
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
        var progressBarColumnTemplate = new Ext.XTemplate(
            '<div class="ux-progress-cell-inner ux-progress-cell-inner-center ux-progress-cell-foreground">',
            '<div>{value} %</div>',
            '</div>',
            '<div class="ux-progress-cell-inner ux-progress-cell-inner-center ux-progress-cell-background" style="left:{value}%">',
            '<div style="left:-{value}%">{value} %</div>',
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
        var self = this;
        var awsomeUploader = {
            xtype:'awesomeuploader',
            ref:'awesomeUploader',
            standardUploadUrl:config['standardUploadUrl'] || './file_manager/base/upload_file',
            flashUploadUrl:config['flashUploadUrl'] ||'./file_manager/base/upload_file',
            xhrUploadUrl:config['xhrUploadUrl'] ||'./file_manager/base/upload_file',
            extraPostData:config['extraPostData'] || {},
            awesomeUploaderRoot:'/awsome_uploader/',
            height:40,
            allowDragAndDropAnywhere:true,
            autoStartUpload:false,
            maxFileSizeBytes: 15 * 1024 * 1024, // 15 MiB,
            listeners:{
                scope:this,
                fileselected:function(awesomeUploader, file){
                    self.awesomeUploaderGrid.store.loadData({
                        id:file.id
                        ,
                        name:file.name
                        ,
                        size:file.size
                        ,
                        status:'Pending'
                        ,
                        progress:0
                    }, true);
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
                        var result = Ext.util.JSON.decode(serverData);//throws a SyntaxError.
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

                    self.awesomeUploaderGrid.store.remove(self.awesomeUploaderGrid.store.getById(file.id) );
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
        };

        config = Ext.apply({
            title:'File Upload',
            frame:true,
            autoWidth:true,
            autoHeight:true,
            iconCls:'icon-upload',
            items:[awsomeUploader,
            {
                xtype:'grid'
                ,
                ref:'awesomeUploaderGrid'
                ,
                width:420
                ,
                height:200
                ,
                enableHdMenu:false
                ,
                tbar:[
                {
                    text:'Start Upload'
                    ,
                    icon:'/images/erp_app/desktop/applications/file_manager/tick.png'
                    ,
                    scope:this
                    ,
                    handler:function(){
                        self.awesomeUploader.startUpload();
                    }
                },{
                    text:'Abort'
                    ,
                    icon:'/images/erp_app/desktop/applications/file_manager/cancel.png'
                    ,
                    scope:this
                    ,
                    handler:function(){
                        var selModel = self.awesomeUploaderGrid.getSelectionModel();
                        if(!selModel.hasSelection()){
                            Ext.Msg.alert('','Please select an upload to cancel');
                            return true;
                        }
                        var rec = selModel.getSelected();
                        self.awesomeUploader.abortUpload(rec.data.id);
                    }
                },{
                    text:'Abort All'
                    ,
                    icon:'/images/erp_app/desktop/applications/file_manager/cancel.png'
                    ,
                    scope:this
                    ,
                    handler:function(){
                        self.awesomeUploader.abortAllUploads();
                    }
                },{
                    text:'Remove'
                    ,
                    icon:'/images/erp_app/desktop/applications/file_manager/cross.png'
                    ,
                    scope:this
                    ,
                    handler:function(){
                        var selModel = self.awesomeUploaderGrid.getSelectionModel();
                        if(!selModel.hasSelection()){
                            Ext.Msg.alert('','Please select an upload to cancel');
                            return true;
                        }
                        var rec = selModel.getSelected();
                        self.awesomeUploader.removeUpload(rec.data.id);
                    }
                },{
                    text:'Remove All'
                    ,
                    icon:'/images/erp_app/desktop/applications/file_manager/cross.png'
                    ,
                    scope:this
                    ,
                    handler:function(){
                        self.awesomeUploader.removeAllUploads();
                    }
                }]
                ,
                store:new Ext.data.JsonStore({
                    fields: ['id','name','size','status','progress']
                    ,
                    idProperty: 'id'
                })
                ,
                columns:[
                {
                    header:'File Name',
                    dataIndex:'name',
                    width:150
                }
                ,{
                    header:'Size',
                    dataIndex:'size',
                    width:60,
                    renderer:Ext.util.Format.fileSize
                }
                ,{
                    header:'&nbsp;',
                    dataIndex:'status',
                    width:30,
                    renderer:self.statusIconRenderer
                }
                ,{
                    header:'Status',
                    dataIndex:'status',
                    width:60
                }
                ,{
                    header:'Progress',
                    dataIndex:'progress',
                    renderer:self.progressBarColumnRenderer
                }
                ]
            }]
        }, config);

        Compass.ErpApp.Shared.UploadWindow.superclass.constructor.call(this, config);
    }

});

Ext.reg('erpappshared_uploadwindow', Compass.ErpApp.Shared.UploadWindow);