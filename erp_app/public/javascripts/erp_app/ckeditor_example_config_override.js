// This is an example of how to override default ckeditor configuration
// place this file in Rails.root/public/javascripts/compass_ae_extensions/erp_app/desktop/applications/knitkit/

//set default config here
Ext.override(Compass.ErpApp.Shared.CKeditor,{
    setupCkEditor : function(){
        Ext.applyIf(this.initialConfig.ckEditorConfig,{
            resize_enabled:false,
            base_path:'/javascripts/ckeditor/',
            toolbarStartupExpanded:true,
            enterMode:CKEDITOR.ENTER_BR,            
            shiftEnterMode:CKEDITOR.ENTER_P,
            baseFloatZIndex:20000,
            extraPlugins:''            
        });
        var editor = CKEDITOR.replace(this.inputEl.id, this.initialConfig.ckEditorConfig);
        editor.extjsPanel = this;
        this.ckEditorInstance = editor;
        this.setValue(this.defaultValue);
    }
});

// set Knitkit toolbar here
Ext.override(Compass.ErpApp.Desktop.Applications.Knitkit.CenterRegion,{
  ckEditorToolbar:[
    ['Source','-','CompassSave','Preview','Print'],
    ['Cut','Copy','Paste','PasteText','PasteFromWord'],
    ['Undo','Redo'],
    ['Find','Replace'],
    ['SpellChecker','-','SelectAll'],
    ['TextColor','BGColor'],
    ['Bold','Italic','Underline','Strike'],
    ['Subscript','Superscript','-','jwplayer'],
    ['Table','NumberedList','BulletedList'],
    ['Outdent','Indent','Blockquote'],
    ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
    ['BidiLtr','BidiRtl'],
    ['Link','Unlink','Anchor'],
    ['HorizontalRule','SpecialChar','PageBreak'],
    ['ShowBlocks','RemoveFormat'],
    ['Styles','Format','Font','FontSize' ],
    ['Maximize','-','About']
  ],
});
