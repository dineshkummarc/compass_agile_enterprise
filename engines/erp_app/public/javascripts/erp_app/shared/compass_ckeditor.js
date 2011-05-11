/**
 * @class Compass.ErpApp.Shared.CKeditor
 * @extends Ext.form.TextArea
 * Converts a textarea into a CkEditor Instance
 * 
 * @author Russell Holmes - russellfholmes@gmail.com / http://www.portablemind.com
 *
 * @additional config options
 * ckEditorConfig - configuration for CkEditor Instance
 */

Ext.ns("Compass.ErpApp.Shared");

Compass.ErpApp.Shared.CKeditor = Ext.extend(Ext.form.TextArea, {
    ckEditorInstance : null,

    initComponent: function() {
        Compass.ErpApp.Shared.CKeditor.superclass.initComponent.call(this, arguments);

        this.addEvents(
            /**
         * @event save
         * Fired when saving contents.
         * @param {Compass.ErpApp.Shared.CKeditor} cKeditor This object
         * @param (contents) contents needing to be saved
         */
            'save'
            );
    },

    constructor : function(config){
        config = Ext.apply({
            grow:true
        },config);
        Compass.ErpApp.Shared.CKeditor.superclass.constructor.call(this, config);
    },

    onRender : function(ct, position){
        Compass.ErpApp.Shared.CKeditor.superclass.onRender.call(this, ct, position);
        this.setupCkEditor();
        this.on('resize', this.textAreaResized, this);
    },

    setupCkEditor : function(){
        Ext.applyIf(this.initialConfig.ckEditorConfig,{
            resize_enabled:false,
            base_path:'/javascripts/ckeditor/',
            toolbarStartupExpanded:false,
            enterMode:CKEDITOR.ENTER_BR,
            shiftEnterMode:CKEDITOR.ENTER_P,
            skin:'office2003',
            extraPlugins:'codemirror'
        });
        var editor = CKEDITOR.replace(this.el.dom.name, this.initialConfig.ckEditorConfig);
        editor.extjsPanel = this;
        this.ckEditorInstance = editor;
    },

    textAreaResized : function(textarea, adjWidth, adjHeight, rawWidth, rawHeight){

        if(!Compass.ErpApp.Utility.isBlank(this.ckEditorInstance))
        {
            if(!Compass.ErpApp.Utility.isBlank(rawWidth) && !Compass.ErpApp.Utility.isBlank(rawHeight)){
                var el = document.getElementById('cke_contents_' + this.id);
                
                if(!Compass.ErpApp.Utility.isBlank(el)){
                    var toolBoxDiv = document.getElementById('cke_top_' + this.id).getElementsByTagName('div')[0];
                    var toolBoxEl = Ext.get(toolBoxDiv);
                    var displayValue = toolBoxEl.getStyle('display');
                    if(displayValue != 'none'){
                        this.ckEditorInstance.execCommand( 'toolbarCollapse' );
                        el.style.height = rawHeight - 51 + 'px';
                        this.ckEditorInstance.execCommand( 'toolbarCollapse' );
                    }
                    else{
                        el.style.height = rawHeight - 51 + 'px';
                    }
					
                }
                else{
                    this.ckEditorInstance.config.height = rawHeight - 51;
                }
            }
        }
    },

    setValue : function(value){
        this.ckEditorInstance.setData(value);
    },

    getValue : function(){
        var value = this.ckEditorInstance.getData();
        return value;
    },

    getRawValue : function(){
        var value = this.ckEditorInstance.getData();
        return value;
    },

    insertHtml : function(html){
        this.ckEditorInstance.insertHtml(html);
    }
});
Ext.reg('ckeditor', Compass.ErpApp.Shared.CKeditor);
