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
                    var codemirrorInit =
                    CodeMirror.fromTextArea(
                        editor.textarea.$, {
                            stylesheet: [Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "xmlcolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "jscolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "csscolors.css"],
                            path: Compass.ErpApp.Shared.CodeMirrorConfig.jsPath,
                            parserfile: ["parsexml.js", "parsecss.js", "tokenizejavascript.js", "parsejavascript.js", "parsehtmlmixed.js"],
                            passDelay: 300,
                            passTime: 35,
                            continuousScanning: 1000, /* Numbers lower than this suck megabytes of memory very quickly out of firefox */
                            undoDepth: 1,
                            height: holderHeight,//editor.config.height || holderHeight, /* Adapt to holder height */
                            textWrapping: false,
                            lineNumbers: false,
                            enterMode: 'flat'
                        }
                        );
                    // Commit source data back into 'source' mode.
                    editor.on( 'beforeCommandExec', function( e ){
                        // Listen to this event once.
                        e.removeListener();
                        editor.textarea.setValue( codemirrorInit.getCode() );
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