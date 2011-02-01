Ext.ns("Compass.ErpApp");

Compass.ErpApp.Shared.CKeditor = Ext.extend(Ext.form.TextArea, {
    ckEditorInstance : null,

    constructor : function(config){
        Compass.ErpApp.Shared.CKeditor.superclass.constructor.call(this, config);
    },

    onRender : function(ct, position){
        if(!this.el){
            this.defaultAutoCreate = {
                tag: "textarea",
                style:"width:100%;height:100%;",
                autocomplete: "off"
            };
        }
        Compass.ErpApp.Shared.CKeditor.superclass.onRender.call(this, ct, position);
        this.setupCkEditor();
    },

    setupCkEditor : function(){
        var editor = CKEDITOR.replace(this.el.dom.name, this.initialConfig.ckEditorConfig);
        editor.ui.addButton( 'CompassUploadFile',
        {
            label : 'Upload File',
            icon:'/images/erp_app/desktop/image_add.png',
            click : function (editor)
            {
                var uploadWindow = new Compass.ErpApp.Shared.UploadWindow();
                uploadWindow.show();
            }
        } );

        this.ckEditorInstance = editor;
    },
    setValue : function(value){
        this.MyValue=value;
        this.ckEditorInstance.setData(value);
        Compass.ErpApp.Shared.CKeditor.superclass.setValue.apply(this,[value]);
    },

    getValue : function(){
        var value = this.ckEditorInstance.getData();
        Ext.form.TextArea.superclass.setValue.apply(this,[value]);
        return Compass.ErpApp.Shared.CKeditor.superclass.getValue(this);
    },

    getRawValue : function(){
        var value = this.ckEditorInstance.getData();
        Ext.form.TextArea.superclass.setRawValue(this, [value]);
        return Compass.ErpApp.Shared.CKeditor.superclass.getRawValue(this);
    }
});
Ext.reg('ckeditor', Compass.ErpApp.Shared.CKeditor);
