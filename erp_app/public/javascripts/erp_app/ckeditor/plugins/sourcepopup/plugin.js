
/**************************************
    Webutler V2.1 - www.webutler.de
    Copyright (c) 2008 - 2011
    Autor: Sven Zinke
    Free for any use
    Lizenz: GPL
**************************************/


CKEDITOR.plugins.add( 'sourcepopup',
{
    lang : [CKEDITOR.lang.detect(CKEDITOR.config.language)],
    
	init : function( editor )
	{
        CKEDITOR.scriptLoader.load( codemirror_rootpath + 'codemirror/editor/js/codemirror.js' );
        CKEDITOR.scriptLoader.load( codemirror_rootpath + 'codemirror/lang/' + CKEDITOR.lang.detect(CKEDITOR.config.language) + '.js' );
        CKEDITOR.document.appendStyleSheet( codemirror_rootpath + 'codemirror/config/editor.css' );
        CKEDITOR.scriptLoader.load( codemirror_rootpath + 'codemirror/codemirror_config.js' );
        
		editor.addCommand( 'source', new CKEDITOR.dialogCommand( 'sourcepopup' ) );
		
		CKEDITOR.dialog.add( 'sourcepopup', this.path + 'dialogs/sourcepopup.js' );
	}
});

