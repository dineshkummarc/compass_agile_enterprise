/**
 * @class Compass.ErpApp.Shared.CKeditor
 * @extends Ext.form.field.TextArea
 * Converts a textarea into a CkEditor Instance
 * 
 * @author Russell Holmes - russellfholmes@gmail.com / http://www.portablemind.com
 *
 * @additional config options
 * ckEditorConfig - configuration for CkEditor Instance
 */

Ext.define("Compass.ErpApp.Shared.CKeditor",{
    extend:"Ext.form.field.TextArea",
    alias:'widget.ckeditor',
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
            grow:true,
            hideLabel:true
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
            shiftEnterMode:CKEDITOR.ENTER_P,
			baseFloatZIndex:19062,
            skin:'office2003',
            extraPlugins:'codemirror'
        });
        var editor = CKEDITOR.replace(this.inputEl.id, this.initialConfig.ckEditorConfig);
        editor.extjsPanel = this;
        this.ckEditorInstance = editor;
        this.setValue(this.defaultValue);
    },

    textAreaResized : function(textarea, adjWidth, adjHeight){

        if(!Compass.ErpApp.Utility.isBlank(this.ckEditorInstance))
        {
            if(!Compass.ErpApp.Utility.isBlank(adjWidth) && !Compass.ErpApp.Utility.isBlank(adjHeight)){
                var el = document.getElementById('cke_contents_' + this.inputEl.id);
                
                if(!Compass.ErpApp.Utility.isBlank(el)){
                    var toolBoxDiv = document.getElementById('cke_top_' + this.inputEl.id).getElementsByTagName('div')[0];
                    var toolBoxEl = Ext.get(toolBoxDiv);
                    var displayValue = toolBoxEl.getStyle('display');
                    if(displayValue != 'none'){
                        this.ckEditorInstance.execCommand( 'toolbarCollapse' );
                        el.style.height = adjHeight - 51 + 'px';
                        this.ckEditorInstance.execCommand( 'toolbarCollapse' );
                    }
                    else{
                        el.style.height = adjHeight - 51 + 'px';
                    }
					
                }
                else{
                    this.ckEditorInstance.config.height = adjHeight - 51;
                }
            }
        }
    },

    setValue : function(value){
        if(this.ckEditorInstance){
            this.ckEditorInstance.setData(value);
        }
        else{
            this.defaultValue = value;
        }
            
    },

    getValue : function(){
        if(this.ckEditorInstance)
            var value = this.ckEditorInstance.getData();
        return value;
    },

    getRawValue : function(){
        if(this.ckEditorInstance)
            var value = this.ckEditorInstance.getData();
        return value;
    },

    insertHtml : function(html){
        this.ckEditorInstance.insertHtml(html);
    }
});