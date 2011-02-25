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
    cssPath: "/javascripts/erp_app/codemirror/",
    jsPath: "/javascripts/erp_app/codemirror/"
});
Ext.apply(Compass.ErpApp.Shared.CodeMirrorConfig, {
    parser: {
        sql: {
            parserfile: ["contrib/sql/js/parsesql.js"],
            stylesheet: Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "contrib/sql/css/sqlcolors.css"
        },
        rb:{
            parserfile: ["contrib/ruby/js/parseruby.js","contrib/ruby/js/tokenizeruby.js"],
            stylesheet: Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "contrib/ruby/css/rubycolors.css"
        },
        rhtml:{
            parserfile: ["parsexml.js", "parsecss.js", "tokenizejavascript.js", "parsejavascript.js","contrib/ruby/js/parseruby.js","contrib/ruby/js/parserubyhtmlmixed.js","contrib/ruby/js/tokenizeruby.js"],
            stylesheet: [Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "contrib/ruby/css/rubycolors.css",Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "xmlcolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "jscolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "csscolors.css"]
        },
        erb:{
            parserfile: ["parsexml.js", "parsecss.js", "tokenizejavascript.js", "parsejavascript.js","contrib/ruby/js/parseruby.js","contrib/ruby/js/parserubyhtmlmixed.js","contrib/ruby/js/tokenizeruby.js"],
            stylesheet: [Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "contrib/ruby/css/rubycolors.css",Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "xmlcolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "jscolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "csscolors.css"]
        },
        dummy:{
            parserfile: ["parsedummy.js"]
        },
        css: {
            parserfile: ["parsecss.js"],
            stylesheet: "/javascripts/erp_app/codemirror/csscolors.css"
        },
        js: {
            parserfile: ["tokenizejavascript.js", "parsejavascript.js"],
            stylesheet: "/javascripts/erp_app/codemirror/jscolors.css"
        },
        html: {
            parserfile: ["parsexml.js", "parsecss.js", "tokenizejavascript.js", "parsejavascript.js"],
            stylesheet: [Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "xmlcolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "jscolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "csscolors.css"]
            
        }
    }
});

Compass.ErpApp.Shared.CodeMirror = Ext.extend(Ext.Panel, {
    codeMirrorInstance : null,

    initComponent: function() {
        Compass.ErpApp.Shared.CodeMirror.superclass.initComponent.call(this, arguments);

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
        var tbarItems = [{
                text: 'Save',
                handler: this.save,
                scope: this
            }, {
                text: 'Undo',
                handler: function() {
                    this.codeMirrorInstance.undo();
                },
                scope: this
            }, {
                text: 'Redo',
                handler: function() {
                    this.codeMirrorInstance.redo();
                },
                scope: this
            }, {
                text: 'Indent',
                handler: function() {
                    this.codeMirrorInstance.reindent();
                },
                scope: this
            }];

        if(!Compass.ErpApp.Utility.isBlank(config['tbarItems'])){
            tbarItems = tbarItems.concat(config['tbarItems']);
        }

        if(Compass.ErpApp.Utility.isBlank(config['disableToolbar'])){
           config['tbar'] = tbarItems
        }

        config = Ext.apply({
            items: [{
                xtype: 'textarea',
                readOnly: false,
                hidden: true,
                value: config['sourceCode']
            }]
        },config);
        Compass.ErpApp.Shared.CodeMirror.superclass.constructor.call(this, config);
    },

    onRender : function(ct, position){
        Compass.ErpApp.Shared.CodeMirror.superclass.onRender.apply(this, arguments);
        this.on('afterlayout', this.setupCodeMirror, this, {
            single: true
        });
    },

    setupCodeMirror : function(){
        var textAreaComp = this.findByType('textarea')[0];
        var self = this;
        this.initialConfig.codeMirrorConfig = Ext.apply({
            content:textAreaComp.getValue(),
            path: Compass.ErpApp.Shared.CodeMirrorConfig.jsPath,
            height: "100%",
            width: "100%",
            continuousScanning: 500,
            textWrapping: false,
            lineNumbers: false,
            onChange:function(){
                var code = self.codeMirrorInstance.getCode();
                self.setValue(code);
            },
            initCallback: function(editor) {
                editor.win.document.body.lastChild.scrollIntoView();
                try {
                    var lineNumber = ((Ext.state.Manager.get("edcmr_" + oThis.itemId + '_lnmbr') !== undefined) ? Ext.state.Manager.get("edcmr_" + oThis.itemId + '_lnmbr') : 1);
                    editor.jumpToLine(lineNumber);
                }catch(e){}
            },
            onChange: function() {
                var code = self.codeMirrorInstance.getCode();
                textAreaComp.setValue(code);
            }
        },this.initialConfig.codeMirrorConfig);
		
        var parserType = this.parser || 'dummy';
        if(Compass.ErpApp.Utility.isBlank(Compass.ErpApp.Shared.CodeMirrorConfig.parser[parserType])){
            parserType = 'dummy';
        }
        var editorConfig = Ext.applyIf(this.initialConfig.codeMirrorConfig, Compass.ErpApp.Shared.CodeMirrorConfig.parser[parserType]);
        this.codeMirrorInstance = new CodeMirror.fromTextArea( Ext.getDom(textAreaComp.id).id, editorConfig);
    },

    save : function(){
        this.fireEvent('save', this, this.getValue());
    },

    setValue : function(value){
        this.codeMirrorInstance.setCode(value);
    },

    getValue : function(){
        return this.codeMirrorInstance.getCode();
    }
});
Ext.reg('codemirror', Compass.ErpApp.Shared.CodeMirror);
