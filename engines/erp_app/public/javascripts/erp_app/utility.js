Ext.override(Ext.data.Store, {
  setExtraParam: function (name, value){
    this.proxy.extraParams = this.proxy.extraParams || {};
    this.proxy.extraParams[name] = value;
    this.proxy.applyEncoding(this.proxy.extraParams);
  }
});

Ext.ns("Compass.ErpApp.Utility.Data");

Compass.ErpApp.Utility.promptReload = function(){
    Ext.MessageBox.confirm('Confirm', 'Page must reload for changes to take affect. Reload now?', function(btn){
        if(btn == 'no'){
            return false;
        }
        else{
            window.location.reload();
        }
    });
};

Compass.ErpApp.Utility.handleFormFailure = function(action){
    switch (action.failureType) {
        case Ext.form.action.Action.CLIENT_INVALID:
            Ext.Msg.alert('Failure', 'Form fields may not be submitted with invalid values');
            break;
        case Ext.form.action.Action.CONNECT_FAILURE:
            Ext.Msg.alert('Failure', 'Ajax communication failed');
            break;
        case Ext.form.action.Action.SERVER_INVALID:
            Ext.Msg.alert('Failure', action.result.msg);
    }
};

Compass.ErpApp.Utility.getRootUrl = function(){
    var url_pieces = location.href.split("/");
    var root_url = url_pieces[0] + url_pieces[1] + "//" + url_pieces[2] + "/"
    return root_url;
};

Compass.ErpApp.Utility.roundNumber = function(num, dec) {
    var result = Math.round(num*Math.pow(10,dec))/Math.pow(10,dec);
    return result;
};

Compass.ErpApp.Utility.numbersOnly = function(e, decimal) {
    var key;
    var keychar;

    if (window.event) {
        key = window.event.keyCode;
    }
    else if (e) {
        key = e.which;
    }
    else {
        return true;
    }
    keychar = String.fromCharCode(key);

    if ((key==null) || (key==0) || (key==8) ||  (key==9) || (key==13) || (key==27) ) {
        return true;
    }
    else if ((("0123456789").indexOf(keychar) > -1)) {
        return true;
    }
    else if (decimal && (keychar == ".")) {
        return true;
    }
    else
        return false;
};


Compass.ErpApp.Utility.clone = function(o) {
    if(!o || 'object' !== typeof o) {
        return o;
    }
    if('function' === typeof o.clone) {
        return o.clone();
    }
    var c = '[object Array]' === Object.prototype.toString.call(o) ? [] : {};
    var p, v;
    for(p in o) {
        if(o.hasOwnProperty(p)) {
            v = o[p];
            if(v && 'object' === typeof v) {
                c[p] = Ext.ux.util.clone(v);
            }
            else {
                c[p] = v;
            }
        }
    }
    return c;
};

Compass.ErpApp.Utility.addCommas = function(nStr)
{
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
};


Compass.ErpApp.Utility.isBlank = function(value) {
    var result = false;

    if(value == 'undefined' || value == undefined || value == null || value == '' || value == ' '){
        result = true;
    }

    return result;
};

Compass.ErpApp.Utility.removeDublicates = function(arrayName) {
    var newArray = new Array();
        label:for (var i = 0; i < arrayName.length; i++)
        {
            for (var j = 0; j < newArray.length; j++)
            {
                if (newArray[j].unit_id == arrayName[i].unit_id)
                    continue label;
            }
            newArray[newArray.length] = arrayName[i];
        }
    return newArray;
};



Array.prototype.contains = function (element) {
    for (var i = 0; i < this.length; i++) {
        if (this[i] == element) {
            return true;
        }
    }
    return false;
};

Array.prototype.find = function (find_statement) {
    try
    {
        for (var i = 0; i < this.length; i++) {
            var statement = "this[i]." + find_statement;
            if(eval(statement)){
                return this[i];
            }
        }
    }
    catch(ex){
        return null;
    }
    return null;
};

Array.prototype.select = function (find_statement) {
    var sub_array = [];
    try
    {
        for (var i = 0; i < this.length; i++) {
            var statement = "this[i]." + find_statement;
            if(eval(statement)){
                sub_array.push(this[i]);
            }
        }
    }
    catch(ex){
        return null;
    }
    return sub_array;
};

Array.prototype.first = function(){
    if(this[0] == undefined){
        return null;
    }
    else{
        return this[0];
    }
};

String.prototype.underscore = function (){
    return this.replace(/\s/g, "_");
};

String.prototype.downcase = function (){
    return this.toLowerCase();
}

Compass.ErpApp.Utility.JsLoader = {
    load : function(url,fireOnSuccess) {
        var ss = document.getElementsByTagName("script");
        for (i = 0;i < ss.length; i++) {
            if (ss[i].src && ss[i].src.indexOf(url) != -1)
            {
                if (fireOnSuccess)
                    this.onSuccess();
                return;
            }
        }
        var s = document.createElement("script");
        s.type = "text/javascript";
        s.src = url;
        var head = document.getElementsByTagName("head")[0];
        head.appendChild(s);
        var self = this;
        s.onload = s.onreadystatechange = function()
        {
            if (this.readyState && this.readyState == "loading")
                return;
            if (fireOnSuccess)
                self.onSuccess();
        }
        s.onerror = function() {
            head.removeChild(s);
            self.onFailure(); 
        }
    },
    onSuccess : function() { },
    onFailure : function() { }
}