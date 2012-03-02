(function(){
    /**
     * @fileOverview The "codemirror" plugin. It's indented to enhance the
     *  "sourcearea" editing mode, which displays the xhtml source code with
     *  syntax highlight and line numbers.
     * @see http://marijn.haverbeke.nl/codemirror/ for CodeMirror editor which this
     *  plugin is using.
     */

    CKEDITOR.plugins.add( 'codemirror', {
        requires : [ 'sourcearea' ],
        /**
         * This's a command-less plugin, auto loaded as soon as switch to 'source' mode
         * and 'textarea' plugin is activeated.
         * @param {Object} editor
         */

        init : function( editor ) {
            editor.on( 'mode', function() {
                if ( editor.mode == 'source' ) {
                    var sourceAreaElement = editor.textarea,
                    holderElement = sourceAreaElement.getParent();
                    var holderHeight = holderElement.$.clientHeight + 'px';
                    editor.getCommand('maximize').setState(CKEDITOR.TRISTATE_DISABLED);
                    editor.getCommand('selectAll').setState(CKEDITOR.TRISTATE_DISABLED);
                    /* http://codemirror.net/manual.html */
                    var codemirrorInit = null;
					Compass.ErpApp.Utility.JsLoader.load([
						'/javascripts/erp_app/codemirror/mode/xml/xml.js',
						'/javascripts/erp_app/codemirror/mode/javascript/javascript.js',
						'/javascripts/erp_app/codemirror/mode/css/css.js',
						'/javascripts/erp_app/codemirror/mode/htmlmixed/htmlmixed.js',
						],function(){
						codemirrorInit =
	                    CodeMirror.fromTextArea(
	                        editor.textarea.$, {
	                            mode:'text/html',
	                            lineNumbers: true,
	                            enterMode: 'flat'
	                        }
	                        );
					});
					
                    // Commit source data back into 'source' mode.
                    editor.on( 'beforeCommandExec', function( e ){
                        // Listen to this event once.
                        e.removeListener();
                        editor.textarea.setValue( codemirrorInit.getValue() );
                        editor.fire( 'dataReady' );
                    } );

                    CKEDITOR.plugins.mirrorSnapshotCmd = {
                        exec : function( editor ) {
                            if ( editor.mode == 'source' ) {
                                editor.textarea.setValue( codemirrorInit.getCode() );
                                editor.fire( 'dataReady' );
                            }
                        }
                    };
                    editor.addCommand( 'mirrorSnapshot', CKEDITOR.plugins.mirrorSnapshotCmd );
                /* editor.execCommand('mirrorSnapshot'); */
                }
            } );
        }

    });
})();