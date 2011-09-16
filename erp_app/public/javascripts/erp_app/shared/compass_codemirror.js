/**
 * @class Ext.ux.panel.CodeMirror
 * @extends Ext.Panel
 * Converts a panel into a code mirror editor with toolbar
 * @constructor
 * 
 * @author Dan Ungureanu - ungureanu.web@gmail.com / http://www.devweb.ro
 * @Enchnaced Russell Holmes
 */

Ext.ns("Compass.ErpApp.Shared");
Ext.ns("Compass.ErpApp.Shared.CodeMirrorConfig");
Ext.apply(Compass.ErpApp.Shared.CodeMirrorConfig, {
    parser: {
        sql: {
			path:'plsql',
			mode:'text/x-plsql'
        },
        rb:{
            path:'ruby',
			mode:'text/x-ruby'
        },
        rhtml:{
            path:'ruby',
			mode:'text/x-ruby'
        },
        erb:{
          	path:'ruby',
			mode:'text/x-ruby'
        },
        css: {
			path:'css',
			mode:'text/css'
        },
        js: {
			path:'javascript',
			mode:'text/javascript'
        },
		yaml:{
			path:'yaml',
			mode:'text/x-yaml'
		},
        html: {
            path:'htmlmixed',
			mode:'text/html'
        }
    }
});

Ext.define("Compass.ErpApp.Shared.CodeMirror",{
    extend:"Ext.Panel",
    requires:["Ext.form.field.TextArea"],
    alias:'widget.codemirror',
    codeMirrorInstance : null,

    initComponent: function() {
        this.callParent(arguments);

        this.addEvents(
            /**
         * @event save
         * Fired when saving contents.
         * @param {Compass.ErpApp.Shared.CodeMirror} codemirror This object
         * @param (contents) contents needing to be saved
         */
            'save'
            );
    },

    constructor : function(config){
        var tbarItems = [];

        if(!config['disableSave']){
            tbarItems.push({
                text: 'Save',
                iconCls:'icon-save',
                handler: this.save,
                scope: this
            });
        }


        tbarItems = tbarItems.concat([{
            text: 'Undo',
            iconCls:'icon-undo',
            handler: function() {
                this.codeMirrorInstance.undo();
            },
            scope: this
        }, {
            text: 'Redo',
            iconCls:'icon-redo',
            handler: function() {
                this.codeMirrorInstance.redo();
            },
            scope: this
        }, {
            text: 'Indent',
            iconCls:'icon-arrow-right-blue',
            handler: function() {
                this.codeMirrorInstance.reindent();
            },
            scope: this
        }]);

        if(!Compass.ErpApp.Utility.isBlank(config['tbarItems'])){
            tbarItems = tbarItems.concat(config['tbarItems']);
        }

        if(Compass.ErpApp.Utility.isBlank(config['disableToolbar']) || !config['disableToolbar']){
            config['tbar'] = tbarItems
        }

        config = Ext.apply({
            layout:'fit',
			autoScroll:true,
			items: [{
                xtype: 'textareafield',
                readOnly: false,
                hidden: true,
                value: config['sourceCode']
            }]
        },config);
        
		this.callParent([config]);
    },

    onRender : function(ct, position){
        Compass.ErpApp.Shared.CodeMirror.superclass.onRender.apply(this, arguments);
        this.on('afterlayout', this.setupCodeMirror, this, {
            single: true
        });
    },

    setupCodeMirror : function(){
        var textAreaComp = this.query('textareafield')[0];
        var self = this;
        this.initialConfig.codeMirrorConfig = Ext.apply({
            undoDepth: 3,
            lineNumbers: true,
			tabMode: "indent",
            onChange: function() {
                var code = self.codeMirrorInstance.getValue();
                textAreaComp.setValue(code);
            }
        },this.initialConfig.codeMirrorConfig);
		
		//setup parser
		var parserType = this.parser || 'html';
		if(Compass.ErpApp.Shared.CodeMirrorConfig.parser[parserType]){
			parserObj = Compass.ErpApp.Shared.CodeMirrorConfig.parser[parserType];
			Compass.ErpApp.Utility.JsLoader.load('/javascripts/erp_app/codemirror/mode/'+parserObj.path+'/'+''+parserObj.path+'.js',function(){
				var editorConfig = Ext.applyIf(self.initialConfig.codeMirrorConfig, {mode:parserObj.mode});
		        	self.codeMirrorInstance = CodeMirror.fromTextArea(Ext.getDom(textAreaComp.id), editorConfig);
				self.setValue(textAreaComp.getValue());
				self.codeMirrorInstance.setCursor(1);
			});
		}
		else{
			self.codeMirrorInstance = CodeMirror.fromTextArea( Ext.getDom(textAreaComp.id), self.initialConfig.codeMirrorConfig);
			self.codeMirrorInstance.setValue(textAreaComp.getValue());
			self.codeMirrorInstance.setCursor(1);
		}
    },

    save : function(){
        this.fireEvent('save', this, this.getValue());
    },

    setValue : function(value){
        this.codeMirrorInstance.setValue(value);
    },

    getValue : function(){
        return this.codeMirrorInstance.getValue();
    },

    insertContent : function(value){
        var currentCode = this.codeMirrorInstance.getValue();
        this.codeMirrorInstance.setValue(currentCode + value);
    }
});
