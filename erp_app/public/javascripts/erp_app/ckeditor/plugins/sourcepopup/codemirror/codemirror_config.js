
/**************************************
    Webutler V2.1 - www.webutler.de
    Copyright (c) 2008 - 2011
    Autor: Sven Zinke
    Free for any use
    Lizenz: GPL
**************************************/


var codemirror_parserfile;
var codemirror_stylesheet;
var codemirror_highlight = true;

if(typeof codemirror_syntaxmode == 'undefined') {
    var codemirror_syntaxmode = '';
}

if(codemirror_syntaxmode == '' || (codemirror_syntaxmode != 'css' && codemirror_syntaxmode != 'js')) {
    codemirror_parserfile = new Array(
            "parsexml.js",
            "parsecss.js",
            "tokenizejavascript.js",
            "parsejavascript.js",
            "../contrib/php/js/tokenizephp.js",
            "../contrib/php/js/parsephp.js",
            "../contrib/php/js/parsephphtmlmixed.js"
        );
    codemirror_stylesheet = new Array(
            codemirror_rootpath + "codemirror/editor/css/xmlcolors.css",
            codemirror_rootpath + "codemirror/editor/css/csscolors.css",
            codemirror_rootpath + "codemirror/editor/css/jscolors.css",
            codemirror_rootpath + "codemirror/editor/contrib/php/css/phpcolors.css"
        );
}

function codemirror_syntax(editor, stylesheet) {
    if(codemirror_highlight == true) {
        editor.setStylesheet(codemirror_rootpath + "codemirror/config/nocolors.css");
        codemirror_highlight = false;
    }
    else {
        editor.setStylesheet(stylesheet);
        codemirror_highlight = true;
    }
}

function codemirror_save() {
    document.forms.codemirror_form.submit();
}

function codemirror_searchpart(editor) {
    var text = prompt(codemirror_lang.searchwins.searchfor, "");
    if (!text) return;
    
    var first = true;
    do {
        var cursor = editor.getSearchCursor(text, first);
        first = false;
        while (cursor.findNext()) {
            cursor.select();
            if (!confirm(codemirror_lang.searchwins.tryagain))
                return;
        }
    }
    while(confirm(codemirror_lang.searchwins.endofdoc));
}

function codemirror_makeButton(title, func, img, menu) {
    var menuId = document.getElementById(menu);
    var button = document.createElement('div');
    button.className = 'button button_out';
    button.onmousedown = new Function("this.className = 'button button_down'");
    button.onmouseup = new Function("this.className = 'button button_up'");
    button.onmouseover = new Function("this.className = 'button button_over'");
    button.onmouseout = new Function("this.className = 'button button_out'");
    menuId.appendChild(button);
    var icon = document.createElement('div');
    icon.className = 'icon';
    icon.title = title;
    icon.onclick = new Function(func);
    icon.style.backgroundImage = 'url(' + codemirror_rootpath + 'codemirror/config/images/' + img + '.png)';
    button.appendChild(icon);
}

