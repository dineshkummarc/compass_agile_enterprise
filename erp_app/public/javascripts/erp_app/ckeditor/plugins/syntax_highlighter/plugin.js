 
CKEDITOR.plugins.add( 'syntax_highlighter',
    {
        
        init: function( editor )
        {
            editor.addCommand( 'syntaxHighlighterDialog', new CKEDITOR.dialogCommand( 'syntaxHighlighterDialog' ));
            editor.ui.addButton( 'SyntaxHighlighterButton',
            {
                label: 'Syntax Highligher',
                command: 'syntaxHighlighterDialog',
                icon: this.path + 'images/syntax_highlighter.png'
            } );
                
            CKEDITOR.dialog.add( 'syntaxHighlighterDialog', function( editor )
            {
                var new_dialog= {
                    title : 'Syntax Highlighter',
                    minWidth : 400,
                    minHeight : 200,
                    contents :
                    [
                    {
                        id : 'config_tab',
                        label : 'Basic Settings',
                        elements :
                        [
                        {
                            type : 'select',
                            id : 'language_syntax',
                            label : 'Language Syntax',
                            //items : [ [ 'ActionScript3' ],[ 'Bash' ],[ 'ColdFusion' ],[ 'C' ],[ 'Cpp' ],[ 'C-Sharp' ],[ 'Erlang' ], [ 'Groovy' ], [ 'Javascript' ], [ 'Java' ],[ 'JavaFx' ],[ 'Perl' ],[ 'PHP' ],[ 'Python' ],[ 'Ruby' ],[ 'Scala' ],[ 'SQL' ],[ 'VB' ],[ 'XML' ] ],
                            items : [  [ 'C' ],  [ 'Javascript' ], [ 'Java' ], [ 'Ruby' ], [ 'SQL' ] ,[ 'XML' ] ],
                            'default' : 'ruby'
                        //,
                        //onChange : function( api ) {
                        // this = CKEDITOR.ui.dialog.select
                        //    alert( 'Current value: ' + this.getValue() );
                        //}
                        },
                        
                        {
                            type : 'select',
                            id : 'highlight_theme',
                            label : 'Highlighter Theme',
                            items : [ [ 'Default' ], [ 'DJango' ], [ 'Eclipse' ], [ 'Emacs' ],[ 'FadeToGray' ],[ 'Midnight' ],[ 'RDark' ]],
                            'default' : 'Eclipse'
                        //,
                        //onChange : function( api ) {
                        // this = CKEDITOR.ui.dialog.select
                        //    alert( 'Current value: ' + this.getValue() );
                        //}
                        },
                                                        
                        {
                            type : 'textarea',
                            id : 'highlighted_text',
                            label : 'Highlighted Text',
                            validate : CKEDITOR.dialog.validate.notEmpty( "Highlight Language field cannot be empty" )
                        } 	 
                        ]
                    },{
                        id : 'config_tab_2',
                        label : 'Advanced Settings',
                        elements :
                        [
                        {
                            type : 'select',
                            id : 'stripe',
                            label : 'Stripe',
                            //items : [ [ 'ActionScript3' ],[ 'Bash' ],[ 'ColdFusion' ],[ 'C' ],[ 'Cpp' ],[ 'C-Sharp' ],[ 'Erlang' ], [ 'Groovy' ], [ 'Javascript' ], [ 'Java' ],[ 'JavaFx' ],[ 'Perl' ],[ 'PHP' ],[ 'Python' ],[ 'Ruby' ],[ 'Scala' ],[ 'SQL' ],[ 'VB' ],[ 'XML' ] ],
                            items : [  [ 'Yes' ],  [ 'No' ]  ],
                            'default' : 'No'
                        //,
                        //onChange : function( api ) {
                        // this = CKEDITOR.ui.dialog.select
                        //    alert( 'Current value: ' + this.getValue() );
                        //}
                        } 	 
                        ]
                    }  
                    ],
                    onOk : function()
                    {
                        var dialog = this;
                        var syntax_brush=dialog.getValueOf( 'config_tab', 'language_syntax' );
                        // perform any translations
                        switch(syntax_brush)
                        {
                            case "Javascript":
                                syntax_brush="JScript";
                                break;
 
 
                        }
                      
                        
                        //-------------------------
                        // check if the shCore is installed
                        // else add <script type="text/javascript" src="/javascripts/erp_app/syntaxhighlighter/scripts/shCore.js"></script>
                        var syntax_highlighter_script_tag = editor.document.getById("syntax_highlighter_script_tag"); 
                        if(syntax_highlighter_script_tag == null){
                            var script_tag = editor.document.createElement( 'script' );
                            //script_tag.setAttribute( 'id','syntax_highlighter_script_tag');
                            script_tag.setAttribute('type','text/javascript');
                            script_tag.setAttribute('src','/javascripts/erp_app/syntaxhighlighter/scripts/shCore.js');
                            editor.insertElement( script_tag );
                        }else{
                            alert("Syntax Highlighter script tag exists");
                        }
                        //-------------------------
                        // check if the brush is installed is installed
                        // else add <script type="text/javascript" src="/javascripts/erp_app/syntaxhighlighter/scripts/shCore.js"></script>
                        var syntax_highlighter_script_brush_tag = editor.document.getById("syntax_highlighter_script_brush_tag"); 
                        if(syntax_highlighter_script_brush_tag == null){
                            var script_tag = editor.document.createElement( 'script' );
                            //script_tag.setAttribute( 'id','syntax_highlighter_script_brush_tag');
                            script_tag.setAttribute('type','text/javascript');
                            script_tag.setAttribute('src','/javascripts/erp_app/syntaxhighlighter/scripts/shBrush'+syntax_brush+'.js');
                            editor.insertElement( script_tag );
                        }else{
                            alert("Syntax Highlighter script tag exists");
                        }
                        
                        //-------------------------
                        // check if style sheets are included
                        // if not <!-- Include *at least* the core style and default theme -->
                        // <link href="css/shCore.css" rel="stylesheet" type="text/css" />
                        // <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" 
                        var syntax_highlighter_core_link_tag = editor.document.getById("syntax_highlighter_core_link_tag"); 
                        if(syntax_highlighter_core_link_tag == null){
                            var link_core_tag = editor.document.createElement( 'link' );
                            //link_core_tag.setAttribute( 'id','syntax_highlighter_core_link_tag');
                            link_core_tag.setAttribute('href','/javascripts/erp_app/syntaxhighlighter/styles/shCoreDefault.css');
                            link_core_tag.setAttribute('type','text/css');
                            link_core_tag.setAttribute('rel','stylesheet');
                            editor.insertElement( link_core_tag );
                        }else{
                            alert("Syntax Highlighter core link tag exists");
                        }
                        //-------------------------
                        // check if style sheets are included
                        // if not <!-- Include *at least* the core style and default theme -->
                        // <link href="css/shCore.css" rel="stylesheet" type="text/css" />
                        // <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" 
                        var syntax_highlighter_theme_link_tag = editor.document.getById("syntax_highlighter_theme_link_tag"); 
                        if(syntax_highlighter_theme_link_tag == null){
                            var link_theme_tag = editor.document.createElement( 'link' );
                            //link_core_tag.setAttribute( 'id','syntax_highlighter_theme_link_tag');
                            link_theme_tag.setAttribute('href','/javascripts/erp_app/syntaxhighlighter/styles/shThemeRDark.css');
                            link_theme_tag.setAttribute('type','text/css');
                            link_core_tag.setAttribute('rel','stylesheet');
                            editor.insertElement( link_theme_tag );
                        }else{
                            alert("Syntax Highlighter theme link tag exists");
                        }
                        
                        //-------------------------
                        // check if the syntaxhighlighter script call has been addedd
                        // else add  <script type="text/javascript">
                        // SyntaxHighlighter.all()
                        // </script>
                        var syntax_highlighter_script_all_tag = editor.document.getById("syntax_highlighter_script_all_tag"); 
                        if(syntax_highlighter_script_all_tag == null){
                            var script_all_tag = editor.document.createElement( 'script' );
                            //script_all_tag.setAttribute( 'id','syntax_highlighter_script_all_tag');
                            script_all_tag.setAttribute('type','text/javascript');
                            
                            var javascript_text= ' SyntaxHighlighter.config.clipboardSwf = "/javascripts/erp_app/syntaxhighlighter/scripts/clipboard.swf";SyntaxHighlighter.all();'
                            script_all_tag.setText(javascript_text);
                            editor.insertElement( script_all_tag );
                        }else{
                            alert("Syntax Highlighter script tag exists");
                        }
                        
                        //-------------------------
                        // add highlighted text
                        var highlight = editor.document.createElement( 'pre' );
                        
                        highlight.setAttribute( 'class','brush: '+ syntax_brush.toLowerCase()+";" );
                        highlight.setText( dialog.getValueOf( 'config_tab', 'highlighted_text' ) );
                        editor.insertElement( highlight );
                    }
                };
                //new_dialog.setValueOf( 'config_tab', 'highlighted_text',editor.getSelection()) ;
                return new_dialog;
            } );
        }
    } );

