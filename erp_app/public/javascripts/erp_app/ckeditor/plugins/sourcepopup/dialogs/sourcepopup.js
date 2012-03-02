
/**************************************
    Webutler V2.1 - www.webutler.de
    Copyright (c) 2008 - 2011
    Autor: Sven Zinke
    Free for any use
    Lizenz: GPL
**************************************/


(function()
{
    CKEDITOR.dialog.add( 'sourcepopup', function( editor )
    {
    	return {
    		onOk : function()
    		{
                var codemirror_data = eval("codemirror_cke_" + editor.name + ".getCode()");
                editor.setData( codemirror_data );
            },
    		onShow : function()
    		{
                this.resize( 700, 450 );
                this.layout();
            },
    		title : editor.lang.sourcepopup.title,
    		minWidth : 700,
    		minHeight : 450,
    		id : 'sourcepopupwin',
    		contents :
            [
        		{
        			id : 'tabsource',
        			label : '',
        			title : '',
        			elements :
                    [
        			    {
            				type : 'html',
        			        html : '<div class="codemirror_ckemenu" id="codemirror_ckemenu_' + editor.name + '"></div>',
                			'style' : 'height: 24px',
                    		onLoad : function()
                    		{
                                eval('codemirror_makeButton(codemirror_lang.button.highlight, "codemirror_syntax(codemirror_cke_' + editor.name + ', codemirror_stylesheet)", "highlight", "codemirror_ckemenu_' + editor.name + '");');
                                eval('codemirror_makeButton(codemirror_lang.button.undo, "codemirror_cke_' + editor.name + '.undo()", "undo", "codemirror_ckemenu_' + editor.name + '");');
                                eval('codemirror_makeButton(codemirror_lang.button.redo, "codemirror_cke_' + editor.name + '.redo()", "redo", "codemirror_ckemenu_' + editor.name + '");');
                                eval('codemirror_makeButton(codemirror_lang.button.reindent, "codemirror_cke_' + editor.name + '.reindent()", "reindent", "codemirror_ckemenu_' + editor.name + '");');
                                eval('codemirror_makeButton(codemirror_lang.button.search, "codemirror_searchpart(codemirror_cke_' + editor.name + ')", "search", "codemirror_ckemenu_' + editor.name + '");');
                    		}
                    	},
                        {
            				type : 'html',
            				id : 'htmlsourcearea',
            		        html : '<div class="codemirror_ckebg" id="codemirror_ckebg_' + editor.name + '"><textarea id="codemirror_ckesource_' + editor.name + '" style="display: none"></textarea></div>',
                    		onShow : function()
                    		{
                                document.getElementById('codemirror_ckesource_' + editor.name).value = editor.getData() ;

                                editor_name = editor.name.replace('-','_')

                                eval('codemirror_cke_' + editor_name + ' = CodeMirror.fromTextArea( "codemirror_ckesource_' + editor.name + '", {\n' +
                                    'height : "100%",\n' +
                                    'parserfile : codemirror_parserfile,\n' +
                                    'stylesheet : codemirror_stylesheet,\n' +
                                    'path : codemirror_rootpath + "codemirror/editor/js/",\n' +
                                    'continuousScanning : 500,\n' +
                                    'lineNumbers : true\n' +
                                '});\n');
                    		},
                    		onHide : function()
                    		{
                                document.getElementById('codemirror_ckesource_' + editor.name).value = '' ;
                                document.getElementById('codemirror_ckebg_' + editor.name).focus() ;
                                var codemirrordiv = document.getElementById('codemirror_ckebg_' + editor.name).getElementsByTagName('div')[0];
                                document.getElementById('codemirror_ckebg_' + editor.name).removeChild(codemirrordiv);
                            }
            			}
                    ]
                }
            ]
        }
    });
    
    CKEDITOR.on('instanceReady', function( evt )
    {
        eval("var codemirror_cke_" + evt.editor.name + ";");
    });

    CKEDITOR.dialog.on( 'resize', function( evt )
    {
        if(this == 'sourcepopup')
        {
            if(document.getElementById('codemirror_ckebg_' + evt.editor.name)) {
            	var data = evt.data;
            	var width = data.width;
            	var height = data.height-46;
                document.getElementById('codemirror_ckebg_' + evt.editor.name).style.height = height + 'px' ;
            }
        }
    }, 'sourcepopup', null, 100);
})();

